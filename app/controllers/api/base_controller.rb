# frozen_string_literal: true

module Api
  class BaseController < ActionController::API
    include Pundit::Authorization
    rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
    rescue_from Exception::AccessDenied, with: :access_denied
    rescue_from ActionController::ParameterMissing, with: :error_during_processing
    if defined?(JSONAPI::Serializer::UnsupportedIncludeError)
      rescue_from JSONAPI::Serializer::UnsupportedIncludeError,
                  with: :error_during_processing
    end
    rescue_from ArgumentError, with: :error_during_processing
    rescue_from ActionDispatch::Http::Parameters::ParseError, with: :error_during_processing
    rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
    rescue_from Discard::RecordNotDiscarded, with: :prevent_associated_data

    around_action :set_timezone

    def content_type
      "application/vnd.api+json"
    end

    protected

    def serialize_collection(collection)
      collection_serializer.new(
        collection[:records],
        collection_options(collection[:pagy]).merge(params: serializer_params)
      ).serializable_hash
    end

    def collection_options(collection)
      {
        links: collection_links(collection),
        meta: collection_meta(collection),
        include: resource_includes,
        fields: sparse_fields
      }
    end

    def serialize_resource(resource)
      @resource = resource

      resource_serializer.new(
        resource,
        resource_options.merge(params: serializer_params)
      ).serializable_hash
    end

    def resource_options
      {
        include: resource_includes,
        fields: sparse_fields,
        meta: meta_attributes.merge(message: flash_message)
      }
    end

    def meta_attributes
      {}
    end

    def flash_message
      return if request.get? || request.head?

      I18n.t(:success, scope: [ :active_record, params[:action].to_sym ], resource: @resource.class.name)
    end

    def paginated_collection
      @paginated_collection ||= collection_paginator.new(collection, params, current_user).call
    end

    def collection_paginator
      ::Shared::Paginate
    end

    def render_serialized_payload(status = 200)
      render json: yield, status:, content_type:
    end

    def render_error_payload(error, status = 422)
      json = if error.is_a?(ActiveModel::Errors)
                { error: error.full_messages.to_sentence, errors: error.messages }
      elsif error.is_a?(Struct)
                { error: error.to_s, errors: error.to_h }
      else
                { error: }
      end

      render json:, status:, content_type:
    end

    def render_success(message, status = 200)
      render json: { message: }, status:
    end

    def render_result(result, ok_status = 200)
      if result.success?
        render_serialized_payload(ok_status) { serialize_resource(result.value) }
      else
        render_error_payload(result.error)
      end
    end

    def current_user
      return nil unless auth_token
      return @current_user if @current_user

      payload = decode_jwt_token(auth_token)
      return render_error_payload(payload.dig(:error, :message), 400) if payload[:error].present?

      @current_user ||= User.find_by(id: payload[:user_id], username: payload[:username])
    end

    def require_current_user
      raise Exception::AccessDenied if current_user.nil?
    end

    def request_includes
      # if API user wants to receive only the bare-minimum
      # the API will return only the main resource without any included
      if params[:include]&.blank?
        []
      elsif params[:include].present?
        params[:include].split(",")
      end
    end

    def resource_includes
      (request_includes || default_resource_includes).map(&:intern)
    end

    # overwrite this method in your controllers to set JSON API default include value
    # https://jsonapi.org/format/#fetching-includes
    # eg.:
    # %w[images variants]
    # ['variant.images', 'line_items']
    def default_resource_includes
      []
    end

    def sparse_fields
      return unless params[:fields].respond_to?(:each)

      fields = {}
      params[:fields]
        .select { |_, v| v.is_a?(String) }
        .each { |type, values| fields[type.intern] = values.split(",").map(&:intern) }
      fields.presence
    end

    def serializer_params
      {
        user: current_user
      }
    end

    def record_not_found
      render_error_payload(I18n.t(:resource_not_found, scope: :errors), 404)
    end

    def access_denied(exception)
      render_error_payload(exception.message, 403)
    end

    def error_during_processing(exception)
      result = error_handler.call(exception:, opts: { user: current_user })

      render_error_payload(result.value[:message], 400)
    end

    def prevent_associated_data(exception)
      render_error_payload(exception.message)
    end

    def error_handler
      "Api::ErrorHandler".constantize
    end

    def user_not_authorized
      render_error_payload(I18n.t(:not_authorized_error, scope: :pundit), 403)
    end

    def set_custom_serializer
      resource.use_custom_serializer = true
    end

    private

    def auth_token
      request.headers[:Authorization]
    end

    def set_timezone(&block)
      timezone = @current_user.is_a?(User) && @current_user.timezone || Time.zone.name
      Time.use_zone(timezone, &block)
    end
  end
end

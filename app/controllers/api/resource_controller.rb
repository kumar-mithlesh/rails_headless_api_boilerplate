# frozen_string_literal: true

module Api
  class ResourceController < Api::BaseController
    include Api::CollectionOptionsHelper
    include Api::Caching
    before_action :require_current_user

    def index
      render_serialized_payload do
        Rails.cache.fetch(collection_cache_key(paginated_collection[:records]), collection_cache_opts) do
          serialize_collection(paginated_collection)
        end
      end
    end

    def new
      resource = model_class.new

      authorize resource
      render_serialized_payload { serialize_resource(resource) }
    end

    def create
      resource = model_class.new(permitted_resource_params)

      authorize resource
      if resource.save
        render_serialized_payload(201) { serialize_resource(resource) }
      else
        render_error_payload(resource.errors)
      end
    end

    def update
      authorize resource
      resource.assign_attributes(permitted_resource_params)

      if resource.save
        render_serialized_payload { serialize_resource(resource) }
      else
        render_error_payload(resource.errors)
      end
    end

    def show
      authorize resource
      render_serialized_payload { serialize_resource(resource) }
    end

    def destroy
      authorize resource
      if resource.destroy
        render_serialized_payload(200) do
          { meta: { message: I18n.t(:success, scope: %i[active_record destroy], resource: model_class.name) } }
        end
      else
        render_error_payload(resource.errors)
      end
    end

    protected

    def collection_serializer
      serializer_klass
    end

    def resource_serializer
      base_name = model_class.to_s
      serializer_klass(base_name)
    end

    def serializer_klass(serializer_base_name = model_class.to_s)
      "Api::#{serializer_base_name}Serializer".constantize
    end

    def custom_serializer_klass
      "#{resource.class.name}::#{params[:action].camelize}"
    end

    def scope
      base_scope = model_class

      base_scope = base_scope.includes(scope_includes) if params[:include].present? && scope_includes.any? && action_name == "index"
      base_scope
    end

    def scope_includes
      []
    end

    def resource
      @resource ||= if defined?(resource_finder)
                      resource_finder.new(scope:, params: finder_params).execute
      else
                      scope.find(params[:id])
      end
    end

    def collection
      @collection ||= if defined?(collection_finder)
                        collection_finder.new(scope:, params: finder_params).execute
      else
                        scope
      end
      @collection = @collection.ransack(params[:filter]).result(distinct: true) if params[:filter]

      @collection
    end

    def model_param_name
      model_class.to_s.demodulize.underscore
    end

    def finder_params
      params.merge(
        user: current_user
      )
    end

    def model_permitted_attributes
      model_class.json_api_permitted_attributes + metadata_params
    end

    def metadata_params
      []
    end

    def permitted_resource_params
      params.require(model_param_name).permit(model_permitted_attributes)
    end
  end
end

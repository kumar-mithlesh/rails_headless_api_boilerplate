# frozen_string_literal: true

module Api
  class AuthenticationController < ResourceController
    skip_before_action :require_current_user

    def signup
      resource = model_class.new(permitted_resource_params)

      if resource.save
        render_serialized_payload(201) { serialize_resource(resource) }
      else
        render_error_payload(resource.errors)
      end
    end

    def login
      if resource.authenticate(permitted_resource_params[:password])
        render_serialized_payload { serialize_resource(resource) }
      else
        render_error_payload(I18n.t(:incorrect_password, scope: %i[models users]))
      end
    end

    def logout
      if resource.present?
        render_serialized_payload { { meta: { message: I18n.t(:logged_out, scope: :success) } } }
      else
        render_error_payload(I18n.t(:record_not_found, scope: %i[models users]))
      end
    end

    def forgot_password
      UserMailer.with(user_id: resource.id).forgot_password_email.deliver_later
      render_serialized_payload { { meta: { message: I18n.t(:forgot_password_email_sent, scope: :success) } } }
    end

    def reset_password
      payload = decode_jwt_token(auth_token)
      return render_error_payload(payload.dig(:error, :message), 400) if payload[:error].present?

      user = User.find(payload[:id])
      user.assign_attributes(permitted_resource_params)

      if user.save
        render_serialized_payload { serialize_resource(user) }
      else
        render_error_payload(user.errors)
      end
    end

    protected

    def meta_attributes
      return super unless action_name == "login"

      { token: generate_jwt_token({ user_id: resource.id, username: resource.username, exp: 7.day.from_now.to_i }) }
    end

    def resource
      key = permitted_resource_params[:username_or_email]&.include?("@") ? "email" : "username"
      @resource ||= scope.find_by!(key => permitted_resource_params[:username_or_email])
    end

    def metadata_params
      %w[password password_confirmation username_or_email]
    end

    def model_class
      User
    end
  end
end

# frozen_string_literal: true

class BaseSerializer
  include JSONAPI::Serializer

  def initialize(object, options = {})
    super
    @current_user = options.dig(:params, :user)
  end
end

# frozen_string_literal: true

class BaseMailer < ApplicationMailer
  before_action :set_base_url

  protected

  def set_base_url
    host, port = default_url_options.values_at(:host, :port)
    protocol = Rails.env.development? ? "http" : "https"

    @base_url ||= "#{protocol}://#{host}#{":#{port}" if port.present? && ![ 80, 443 ].include?(port)}"
  end
end

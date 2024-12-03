# frozen_string_literal: true

class UserMailer < ApplicationMailer
  before_action :current_user, only: %w[forgot_password_email]

  def forgot_password_email
    @token = generate_jwt_token({ id: current_user.id, exp: 7.day.from_now.to_i })
    mail(to: current_user.email, subject: I18n.t(:reset_password, scope: %i[mailer user_email]))
  end

  private

  def current_user
    return @current_user if @current_user.present?

    @current_user = User.find_by(id: params[:user_id]) if params[:user_id].present?
  end
end

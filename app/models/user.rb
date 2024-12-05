class User < Base
  has_secure_password(validations: false)

  with_options presence: true do
    validates :password, confirmation: true, if: -> { password_digest_changed? || new_record? }
    validates :password_confirmation, presence: true, if: -> { password.present? }
    validates :email, uniqueness: { message: "is already in use" }, format: { with: URI::MailTo::EMAIL_REGEXP }
  end

  def self.json_api_permitted_attributes
    skipped_attributes = %w[id password_digest]

    column_names.reject { |c| skipped_attributes.include?(c.to_s) }
  end
end

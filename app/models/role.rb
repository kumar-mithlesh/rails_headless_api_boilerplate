class Role < Base
  has_many :user_roles
  has_many :users, through: :user_roles

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  def self.json_api_permitted_attributes
    skipped_attributes = %w[id]

    column_names.reject { |c| skipped_attributes.include?(c.to_s) }
  end
end

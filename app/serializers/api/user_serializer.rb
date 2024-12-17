module Api
  class UserSerializer < BaseSerializer
    set_type :user

    has_many :roles
    attributes :email, :username
  end
end

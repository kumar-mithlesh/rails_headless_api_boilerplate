class UserSerializer < BaseSerializer
  set_type :user

  attributes :email, :username
end

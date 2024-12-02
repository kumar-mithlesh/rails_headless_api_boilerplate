class User < Base
  has_secure_password(validations: false)
end

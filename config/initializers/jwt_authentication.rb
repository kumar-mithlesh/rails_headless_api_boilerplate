# frozen_string_literal: true

require "jwt"

def generate_jwt_token(payload)
  JWT.encode(payload, secret_key, "HS256")
end

def decode_jwt_token(token)
  JWT.decode(token, secret_key, true, algorithm: "HS256").first.with_indifferent_access
rescue StandardError => e
  { error: { name: e.class.name, message: e.message } }
end

def secret_key
  Rails.application.credentials[:secret_key_base]
end

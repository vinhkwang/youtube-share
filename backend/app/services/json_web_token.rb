module JsonWebToken
  SECRET = Rails.application.secret_key_base
  EXPIRY  = 7.days

  def self.encode(payload)
    payload[:exp] = EXPIRY.from_now.to_i
    JWT.encode(payload, SECRET, "HS256")
  end

  def self.decode(token)
    body = JWT.decode(token, SECRET, true, algorithm: "HS256").first
    HashWithIndifferentAccess.new(body)
  rescue JWT::ExpiredSignature
    raise JsonWebToken::Errors::TokenExpired
  rescue JWT::DecodeError
    raise JsonWebToken::Errors::InvalidToken
  end

  module Errors
    class TokenExpired  < StandardError; end
    class InvalidToken  < StandardError; end
    class MissingToken  < StandardError; end
  end
end

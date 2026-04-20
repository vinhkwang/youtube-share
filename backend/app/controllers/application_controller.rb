class ApplicationController < ActionController::API
  def authenticate_user!
    current_user
  rescue JsonWebToken::Errors::TokenExpired
    render_error("Token has expired. Please log in again.", :unauthorized)
  rescue JsonWebToken::Errors::InvalidToken
    render_error("Invalid token.", :unauthorized)
  rescue JsonWebToken::Errors::MissingToken
    render_error("Authorization token missing.", :unauthorized)
  end

  def current_user
    @current_user ||= begin
      token   = extract_token_from_header
      payload = JsonWebToken.decode(token)
      User.find(payload[:user_id])
    rescue ActiveRecord::RecordNotFound
      raise JsonWebToken::Errors::InvalidToken
    end
  end

  def render_error(message, status = :unprocessable_entity)
    render json: { error: message }, status: status
  end

  def render_errors(messages, status = :unprocessable_entity)
    render json: { errors: Array(messages) }, status: status
  end

  private

  def extract_token_from_header
    header = request.headers["Authorization"]
    raise JsonWebToken::Errors::MissingToken if header.blank?

    token = header.split(" ").last
    raise JsonWebToken::Errors::MissingToken if token.blank?

    token
  end
end

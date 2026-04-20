module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    def find_verified_user
      token = request.params[:token]
      return nil if token.blank?

      payload = JsonWebToken.decode(token)
      User.find_by(id: payload[:user_id])
    rescue JsonWebToken::Errors::TokenExpired,
           JsonWebToken::Errors::InvalidToken
      nil  
    end
  end
end

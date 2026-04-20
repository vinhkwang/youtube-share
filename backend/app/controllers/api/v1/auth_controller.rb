module Api
  module V1
    class AuthController < ApplicationController
      before_action :authenticate_user!, only: [:me]

      def register
        user = User.new(register_params)

        if user.save
          render json: {
            user:  user.as_public_json,
            token: user.generate_jwt
          }, status: :created
        else
          render_errors(user.errors.full_messages, :unprocessable_entity)
        end
      end

      def login
        user = User.find_by(email: login_params[:email].to_s.downcase.strip)

        if user&.authenticate(login_params[:password])
          render json: {
            user:  user.as_public_json,
            token: user.generate_jwt
          }, status: :ok
        else
          render_error("Invalid email or password.", :unauthorized)
        end
      end

      def me
        render json: { user: current_user.as_public_json }, status: :ok
      end

      private

      def register_params
        params.require(:user).permit(
          :email, :username, :password, :password_confirmation
        )
      rescue ActionController::ParameterMissing
        params.permit(:email, :username, :password, :password_confirmation)
      end

      def login_params
        params.permit(:email, :password)
      end
    end
  end
end

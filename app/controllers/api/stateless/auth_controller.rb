# frozen_string_literal: true
module Api
  module Stateless
    # Api::AuthController allows clients to authenticate and receive a
    # token in response
    class AuthController < StatelessController
      before_filter :authenticate_request!, only: [:test_authentication]

      def password
        credentials = password_authentication_params
        member = Member.find_by(email: credentials[:email])

        return head(:unauthorized) unless member.try(:authenticate, credentials[:password])

        render status: :ok, json: {
          member: member,
          token: encode_jwt(member.token_payload)
        }
      end

      def facebook
        head(:not_implemented)
      end

      # placeholder to test that authentication actually workks...
      # GET /api/auth/test_authentication
      # Responses:
      #  - without headers and you should get 401 unauthorized
      #  - with `Authorization: Bearer <token>` headers you should get
      #    a 200 OK with the member as the json payload
      #  - invalid tokens, malformed requests, etc. should also trigger a
      #    meaningful response.
      def test_authentication
        render json: { member: @current_member }, status: :ok
      end

      protected

      def password_authentication_params
        params.require(:credentials).permit(:email, :password)
      end
    end
  end
end

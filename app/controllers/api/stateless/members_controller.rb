module Api
  module Stateless
    class MembersController < StatelessController
      before_filter :authenticate_request!

      def show
        @current_member
      end

      def update
        permitted_params = params.require(:member).permit(:first_name, :last_name, :email, :country, :city, :postal, :address1, :address2)
        @current_member.update(permitted_params)
        unless @current_member.save
          render json: { success: false, errors: @current_member.errors.messages }, status: 422
        end
      end
    end
  end
end

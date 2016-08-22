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
        if @current_member.save
          update_on_ak(@current_member)
          @current_member
        else
          render json: { success: false, errors: @current_member.errors.messages }, status: 422
        end
      end

      private

      def update_on_ak(member)
        ChampaignQueue.push(
          type: 'update_member',
          params: {
            akid: member.actionkit_user_id,
            email: member.email,
            first_name: member.first_name,
            last_name: member.last_name,
            country: member.country,
            city: member.city,
            postal: member.postal,
            address1: member.address1,
            address2: member.address2
          }
        )
      end
    end
  end
end

# frozen_string_literal: true

module Api
  module Stateless
    class MembersController < StatelessController
      before_action :authenticate_request!, except: [:create]

      def show
        @current_member
      end

      def update
        @current_member.update(permitted_params)
        if @current_member.save
          update_on_ak(@current_member)
        else
          render json: { success: false, errors: @current_member.errors.messages }, status: 422
        end
      end

      def create
        builder = MemberWithAuthentication.create(permitted_params)

        if builder.errors.any?
          respond_to do |format|
            format.json { render json: { errors: builder.errors.messages }, status: 422 }
          end
        else
          ConfirmationMailer.confirmation_email(
            email: builder.member.email,
            token: builder.authentication.token
          ).deliver_now

          respond_to do |format|
            format.json { render json: builder.member }
          end
        end
      end

      private

      def permitted_params
        params
          .require(:member)
          .permit(:first_name,
                  :last_name,
                  :name, :email,
                  :country, :city,
                  :postal, :address1, :address2,
                  :password, :password_confirmation)
      end

      def update_on_ak(member)
        ChampaignQueue.push({
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
        }, { group_id: "member:#{member.id}" })
      end
    end
  end
end

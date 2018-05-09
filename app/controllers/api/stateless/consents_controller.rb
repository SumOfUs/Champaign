# frozen_string_literal: true

module Api
  module Stateless
    class ConsentsController < StatelessController
      rescue_from ActiveRecord::RecordNotFound, with: :not_found

      def create
        member = Member.find_by_id_and_email! params[:member_id], params[:email]
        member.update!(consented: true)
        render json: member
      end

      def destroy
        member = Member.find_by_email! params[:email]
        member.update!(consented: false)
      end

      private

      def not_found
        render json: { error: 'No member was found.' }, status: 404
      end
    end
  end
end

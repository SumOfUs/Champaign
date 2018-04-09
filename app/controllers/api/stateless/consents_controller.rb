# frozen_string_literal: true

module Api
  module Stateless
    class ConsentsController < StatelessController
      rescue_from ActiveRecord::RecordNotFound, with: :not_found

      def create
        member = Member.find_by_id_and_email! params[:member_id], params[:email]
        member.update(consented_at: Time.now)
        render json: member
      end

      private

      def not_found
        render json: { error: 'No member was found.' }, status: 404
      end
    end
  end
end

# frozen_string_literal: true

module Api
  module Stateless
    module GoCardless
      class TransactionsController < StatelessController
        before_action :authenticate_request!, only: [:index]
        before_action :check_api_key, only: [:update]

        def index
          @transactions = PaymentHelper::GoCardless.transactions_for_member(@current_member)
        end

        def update
          @transaction = PaymentHelper::GoCardless.find_transaction_by(id: params[:id])
          unless @transaction.present?
            render json: { success: false, message: 'record not found' }, header: :not_found
            return false
          end
          status = @transaction.update_columns(transaction_params)
          render json: { success: status, message: (status ? 'record updated' : 'record not updated') }, header: :ok
        end

        private

        def transaction_params
          request.params.slice(:ak_order_id, :ak_donation_action_id, :ak_transaction_id, :ak_user_id)
        end
      end
    end
  end
end

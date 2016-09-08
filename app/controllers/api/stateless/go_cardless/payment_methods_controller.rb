# frozen_string_literal: true
module Api
  module Stateless
    module GoCardless
      class PaymentMethodsController < StatelessController
        before_filter :authenticate_request!

        def index
          @payment_methods = PaymentHelper::GoCardless.payment_methods_for_member(@current_member)
        end

        def destroy
          @payment_method = PaymentHelper::GoCardless.payment_method_for_member(member: @current_member, id: params[:id])
          PaymentProcessor::GoCardless::Populator.client.mandates.cancel(@payment_method.go_cardless_id)
          @payment_method.update(cancelled_at: Time.now)
          render json: { success: true }
        rescue GoCardlessPro::InvalidApiUsageError,
          GoCardlessPro::InvalidStateError,
          GoCardlessPro::ValidationError,
          GoCardlessPro::GoCardlessError => e
          render json: { success: false, errors: e.errors }, status: e.code
          Rails.logger.error("#{e} occurred when cancelling mandate #{@payment_method.go_cardless_id}: #{e.message}")
        end
      end
    end
  end
end

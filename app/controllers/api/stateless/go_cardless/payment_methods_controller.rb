# frozen_string_literal: true
module Api
  module Stateless
    module GoCardless
      class PaymentMethodsController < StatelessController
        before_action :authenticate_request!

        def index
          @payment_methods = PaymentHelper::GoCardless.payment_methods_for_member(@current_member).active
        end

        def destroy
          e = GoCardlessCancellationService.cancel_mandate(@current_member, params)
          if e.blank?
            render json: { success: true }
          else
            render json: { success: false, errors: e.errors }, status: e.code
          end
        end
      end
    end
  end
end

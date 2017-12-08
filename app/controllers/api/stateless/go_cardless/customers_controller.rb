# frozen_string_literal: true

module Api
  module Stateless
    module GoCardless
      class CustomersController < StatelessController
        before_action :authenticate_member_services

        def index
          @payment_methods = PaymentHelper::GoCardless.payment_methods_for_member(@current_member).active
        end

        def destroy
          e = GoCardlessCancellataionService.cancel_mandate(@current_member, params)
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

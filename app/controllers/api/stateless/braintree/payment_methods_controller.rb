# frozen_string_literal: true
module Api
  module Stateless
    module Braintree
      class PaymentMethodsController < StatelessController
        before_action :authenticate_request!

        def index
          @payment_methods = PaymentHelper::Braintree.payment_methods_for_member(@current_member).active
        end

        def destroy
          @payment_method = PaymentHelper::Braintree.payment_method_for_member(member: @current_member, id: params[:id])

          begin
            ::Braintree::PaymentMethod.delete(@payment_method.token)
          rescue ::Braintree::NotFoundError
            Rails.logger.error("Payment Method #{@payment_method.token} not found on Braintree")
          end

          @payment_method.update(cancelled_at: Time.now)
          PaymentHelper::Braintree.active_subscriptions_for_payment_method(@payment_method)
            .update_all(cancelled_at: Time.now)
          render json: { success: true }
        end
      end
    end
  end
end

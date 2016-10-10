# frozen_string_literal: true
module Api
  module Stateless
    module Braintree
      class PaymentMethodsController < StatelessController
        before_filter :authenticate_request!

        def index
          @payment_methods = PaymentHelper::Braintree.payment_methods_for_member(@current_member)
        end

        def destroy
          @payment_method = PaymentHelper::Braintree.payment_method_for_member(member: @current_member, id: params[:id])

          result = begin
                     ::Braintree::PaymentMethod.delete(@payment_method.token)
                   rescue ::Braintree::NotFoundError
                     @payment_method.destroy
                   end

          @payment_method.destroy if result.success?

          # TODO: return something else if `destroy` returns false.
          render json: { success: true }
        end
      end
    end
  end
end

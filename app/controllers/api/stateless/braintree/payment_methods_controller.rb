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
          result = ::Braintree::PaymentMethod.delete(@payment_method.token)
          if result.success?
            @payment_method.destroy
            render json: @payment_method.slice(:id, :token)
          else
            render json: { success: false, errors: result.errors }
          end
        rescue ::Braintree::NotFoundError
          @payment_method.destroy
          render json: { success: true }
        end
      end
    end
  end
end

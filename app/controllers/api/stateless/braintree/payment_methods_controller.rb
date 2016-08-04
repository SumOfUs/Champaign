# frozen_string_literal: true

module Api
  module Stateless
    module Braintree
      class PaymentMethodsController < StatelessController
        before_filter :authenticate_request!

        def index
          @payment_methods = @current_member.braintree_customer.payment_methods
        end

      end
    end
  end
end

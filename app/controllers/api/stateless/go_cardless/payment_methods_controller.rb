# frozen_string_literal: true
module Api
  module Stateless
    module GoCardless
      class PaymentMethodsController < StatelessController
        before_filter :authenticate_request!

        def index
          @payment_methods = PaymentHelper::GoCardless.payment_methods_for_member(@current_member)
        end
      end
    end
  end
end

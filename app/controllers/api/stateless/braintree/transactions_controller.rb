module Api
  module Stateless
    module Braintree
      class TransactionsController < StatelessController
        before_filter :authenticate_request!

        def index
          @transactions = PaymentHelper::Braintree.transactions_for_member(@current_member)
        end

      end
    end
  end
end

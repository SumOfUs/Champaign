# frozen_string_literal: true
module Api
  module Stateless
    module GoCardless
      class TransactionsController < StatelessController
        before_filter :authenticate_request!

        def index
          @transactions = PaymentHelper::GoCardless.transactions_for_member(@current_member)
        end
      end
    end
  end
end

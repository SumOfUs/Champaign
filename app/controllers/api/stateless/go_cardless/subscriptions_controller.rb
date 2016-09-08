# frozen_string_literal: true
module Api
  module Stateless
    module GoCardless
      class SubscriptionsController < StatelessController
        before_filter :authenticate_request!

        def index
          @subscriptions = PaymentHelper::GoCardless.subscriptions_for_member(@current_member)
        end
      end
    end
  end
end

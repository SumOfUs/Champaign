# frozen_string_literal: true
module Api
  module Stateless
    module GoCardless
      class SubscriptionsController < StatelessController
        before_filter :authenticate_request!

        def index
          @subscriptions = PaymentHelper::GoCardless.active_subscriptions_for_member(@current_member)
        end

        def destroy
          e = GoCardlessCancellationService.cancel_subscription(@current_member, params)
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

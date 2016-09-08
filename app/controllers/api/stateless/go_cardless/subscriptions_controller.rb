# frozen_string_literal: true
module Api
  module Stateless
    module GoCardless
      class SubscriptionsController < StatelessController
        before_filter :authenticate_request!

        def index
          @subscriptions = PaymentHelper::GoCardless.subscriptions_for_member(@current_member)
        end

        def destroy
          begin
            @subscription = PaymentHelper::GoCardless.subscription_for_member(member: @current_member, id: params[:id])
            PaymentProcessor::GoCardless::Subscription.cancel(@subscription.go_cardless_id)
            @subscription.update(cancelled_at: Time.now)
            render json: {success: true}
          rescue => e
            render json: {success: false, errors: e.errors}, status: e.code
          end
        end
      end
    end
  end
end

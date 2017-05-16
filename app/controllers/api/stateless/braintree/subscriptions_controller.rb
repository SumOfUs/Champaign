# frozen_string_literal: true
module Api
  module Stateless
    module Braintree
      class SubscriptionsController < StatelessController
        before_action :authenticate_request!

        def index
          @subscriptions = PaymentHelper::Braintree.active_subscriptions_for_member(@current_member)
        end

        def destroy
          @subscription = PaymentHelper::Braintree.subscription_for_member(member: @current_member, id: params[:id])
          result = ::Braintree::Subscription.cancel(@subscription.subscription_id)

          if result.success?
            cancel_subscription
            render json: @subscription.slice(:id, :subscription_id)
          else
            render json: { success: false, errors: result.errors }, status: 422
          end
        rescue ::Braintree::NotFoundError
          cancel_subscription
          render json: { success: true }
        end

        private

        def cancel_subscription
          @subscription.update(cancelled_at: Time.now)
          @subscription.publish_cancellation('user')
        end
      end
    end
  end
end

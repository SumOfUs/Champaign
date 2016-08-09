module Api
  module Stateless
    module Braintree
      class SubscriptionsController < StatelessController
        before_filter :authenticate_request!

        def index
          @subscriptions = PaymentHelper::Braintree.subscriptions_for_member(@current_member)
        end

        def destroy
          @subscription = PaymentHelper::Braintree.subscription_for_member(member: @current_member, id: params[:id])
          result = ::Braintree::Subscription.cancel(@subscription.subscription_id)
          if result.success?
            @subscription.destroy
            render json: { success: true }
          else
            render json: { success: false, errors: result.errors}
          end
          rescue ::Braintree::NotFoundError
            @subscription.destroy
            render json: { success: true }
        end
      end
    end
  end
end

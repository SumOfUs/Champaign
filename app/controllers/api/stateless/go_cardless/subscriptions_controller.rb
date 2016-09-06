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
          @subscription = PaymentHelper::GoCardless.subscription_for_member(member: @current_member, id: params[:id])
        #   result = request on GoCardless to cancel subscription
        #   result.success?
        #   render json: {success: true}
        #   else
        #   render json: {success: false, errors: result.errors}
        # end
      end
    end
  end
end

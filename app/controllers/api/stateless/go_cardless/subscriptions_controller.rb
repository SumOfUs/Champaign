# frozen_string_literal: true

module Api
  module Stateless
    module GoCardless
      class SubscriptionsController < StatelessController
        before_action :authenticate_request!, only: %i[index destroy]
        before_action :check_api_key, only: [:update]

        def index
          @subscriptions = PaymentHelper::GoCardless.active_subscriptions_for_member(@current_member)
        end

        def update
          @subscription = ::Payment::GoCardless::Subscription.find_by(go_cardless_id: params[:id])
          unless @subscription.present?
            render json: { success: false, message: 'record not found' }, header: :not_found
            return false
          end
          status = @subscription.update_columns(subscription_params)
          render json: { success: status, message: (status ? 'record updated' : 'record not updated') }, header: :ok
        end

        def destroy
          e = GoCardlessCancellationService.cancel_subscription(@current_member, params)
          if e.blank?
            render json: { success: true }
          else
            render json: { success: false, errors: e.errors }, status: e.code
          end
        end

        private

        def subscription_params
          request.params.slice(:ak_order_id)
        end
      end
    end
  end
end

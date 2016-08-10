module Api
  module Stateless
    module Braintree
      class SubscriptionsController < StatelessController
        before_filter :authenticate_request!

        def index
          @subscriptions = subscriptions_for_member(@current_member)
        end

        def destroy
          @subscription = subscription_for_member(member: @current_member, id: params[:id])

          begin
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

        private

        def customer(member)
          ::Payment::Braintree::Customer.find_by!(member_id: member.id)
        end

        def subscriptions_for_member(member)
          customer(member).subscriptions.order('created_at desc')
        end

        def subscription_for_member(member:, id:)
          customer(member).subscriptions.find(id)
        end
      end
    end
  end
end

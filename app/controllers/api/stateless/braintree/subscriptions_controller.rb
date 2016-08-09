module Api
  module Stateless
    module Braintree
      class SubscriptionsController < StatelessController
        before_filter :authenticate_request!

        def index
          @subscriptions = subscriptions_for_member(@current_member)
        end

        private

        # Duplicate: where to put this?
        def customer(member)
          ::Payment::Braintree::Customer.find_by!(member_id: member.id)
        end

        def subscriptions_for_member(member)
          customer(member).subscriptions.order('created_at desc')
        end
      end
    end
  end
end

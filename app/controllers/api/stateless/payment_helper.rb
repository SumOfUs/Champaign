# frozen_string_literal: true
module PaymentHelper
  module Braintree
    module_function

    def customer(member)
      ::Payment::Braintree::Customer.find_by!(member_id: member.id)
    end

    def payment_methods_for_member(member)
      customer(member).payment_methods.order('created_at desc')
    end

    def payment_method_for_member(member:, id:)
      customer(member).payment_methods.find(id)
    end

    def subscriptions_for_member(member)
      customer(member).subscriptions.order('created_at desc')
    end

    def subscription_for_member(member:, id:)
      customer(member).subscriptions.find(id)
    end

    def transactions_for_member(member)
      customer(member).transactions.where(subscription_id: nil)
    end
  end
end

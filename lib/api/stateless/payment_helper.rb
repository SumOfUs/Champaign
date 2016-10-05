# frozen_string_literal: true
module Api
  module Stateless
    module PaymentHelper
      module Braintree
        module_function

        def customer(member)
          ::Payment::Braintree::Customer.find_or_initialize_by(member_id: member.id)
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
          customer(member).transactions.one_off
        end
      end

      module GoCardless
        module_function

        def customer(member)
          ::Payment::GoCardless::Customer.find_or_initialize_by(member_id: member.id)
        end

        def transactions_for_member(member)
          customer(member).transactions.one_off
        end

        def subscriptions_for_member(member)
          customer(member).subscriptions.order('created_at desc')
        end

        def subscription_for_member(member:, id:)
          customer(member).subscriptions.find(id)
        end

        def payment_methods_for_member(member)
          customer(member).payment_methods.order('created_at desc')
        end

        def payment_method_for_member(member:, id:)
          customer(member).payment_methods.find(id)
        end
      end
    end
  end
end

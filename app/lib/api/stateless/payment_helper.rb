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
          customer(member).payment_methods.stored.active.order('created_at desc')
        end

        def payment_method_for_member(member:, id:)
          payment_methods_for_member(member).find(id)
        end

        def active_subscriptions_for_member(member)
          customer(member).subscriptions.active.order('created_at desc')
        end

        def subscription_for_member(member:, id:)
          customer(member).subscriptions.find(id)
        end

        def transactions_for_member(member)
          customer(member).transactions.one_off
        end

        def active_subscriptions_for_payment_method(payment_method)
          ::Payment::Braintree::Subscription.active.where(payment_method_id: payment_method.id)
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

        def active_subscriptions_for_member(member)
          customer(member).subscriptions.active.order('created_at desc')
        end

        def subscription_for_member(member:, id:)
          customer(member).subscriptions.find(id)
        end

        def payment_methods_for_member(member)
          customer(member).payment_methods.active.order('created_at desc')
        end

        def payment_method_for_member(member:, id:)
          customer(member).payment_methods.find(id)
        end

        def active_subscriptions_for_payment_method(payment_method)
          ::Payment::GoCardless::Subscription.active.where(payment_method_id: payment_method.id)
        end

        def find_transaction_by(id:)
          ::Payment::GoCardless::Transaction.find_by(go_cardless_id: id)
        end
      end
    end
  end
end

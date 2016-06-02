module Payment::GoCardless
  class << self
    def table_name_prefix
      'payment_go_cardless_'
    end

    def write_customer(customer_gc_id, member_id)
      local_customer = Payment::GoCardless::Customer.find_or_initialize_by(go_cardless_id: customer_gc_id)
      local_customer.update_attributes(member_id: member_id)
      local_customer
    end

    def write_mandate(mandate_gc_id, scheme, next_possible_charge_date, customer_id)
      local_mandate = Payment::GoCardless::PaymentMethod.find_or_initialize_by(go_cardless_id: mandate_gc_id)
      local_mandate.update_attributes(scheme: scheme, next_possible_charge_date: next_possible_charge_date, customer_id: customer_id)
      local_mandate
    end

    def write_transaction(transaction_gc_id, amount, currency, page_id, subscription = nil)
      local_transaction = Payment::GoCardless::Transaction.find_or_initialize_by(go_cardless_id: transaction_gc_id)
      local_transaction.update_attributes(amount: amount, currency: currency, page_id: page_id, subscription: subscription)
      local_transaction
    end

    def write_subscription(subscription_gc_id, amount, currency, page_id)
      local_subscription = Payment::GoCardless::Subscription.find_or_initialize_by(go_cardless_id: subscription_gc_id)
      local_subscription.update_attributes(amount: amount, currency: currency, page_id: page_id)
      local_subscription
    end
  end
end

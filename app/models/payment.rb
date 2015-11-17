module Payment
  class << self
    def table_name_prefix
      'payment_'
    end

    def write_transaction(transaction:, provider:)
      sale = transaction.transaction

      attrs = {
        transaction_id: sale.id,
        transaction_type: sale.type,
        amount: sale.amount,
        transaction_created_at: sale.created_at
      }

      ::Payment::BraintreeTransaction.create(attrs)
    end
  end
end


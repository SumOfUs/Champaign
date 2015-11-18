module Payment
  class << self
    def table_name_prefix
      'payment_'
    end

    def write_transaction(transaction:, provider:)
      sale = transaction.transaction
      card = sale.credit_card_details
      customer = sale.customer_details

      attrs = {
        transaction_id: sale.id,
        transaction_type: sale.type,
        amount: sale.amount,
        transaction_created_at: sale.created_at
      }

      ::Payment::BraintreeTransaction.create(attrs)

      customer = {
        card_type: card.card_type,
        card_bin: card.bin,
        cardholder_name: card.cardholder_name,
        card_debit: card.debit,
        card_last_4: card.last_4,
        card_vault_token: card.token,
        email: customer.email,
        first_name: customer.first_name,
        last_name: customer.last_name,
        customer_id: customer.id
      }

      ::Payment::BraintreeCustomer.create(customer)
    end
  end
end


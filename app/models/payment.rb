module Payment
  class << self
    def table_name_prefix
      'payment_'
    end

    def write_transaction(transaction:, provider: :braintree)
      BraintreeTransactionBuilder.new(transaction).build
    end
  end

  class BraintreeTransactionBuilder
    def initialize(transaction)
      @transaction = transaction
    end

    def build
      ::Payment::BraintreeTransaction.create(transaction_attrs)
      ::Payment::BraintreeCustomer.create(customer_attrs)
    end

    private

    def transaction_attrs
     {
        transaction_id:         sale.id,
        transaction_type:       sale.type,
        amount:                 sale.amount,
        transaction_created_at: sale.created_at
      }
    end

    def customer_attrs
      {
        card_type:        card.card_type,
        card_bin:         card.bin,
        cardholder_name:  card.cardholder_name,
        card_debit:       card.debit,
        card_last_4:      card.last_4,
        card_vault_token: card.token,
        email:            customer.email,
        first_name:       customer.first_name,
        last_name:        customer.last_name,
        customer_id:      customer.id
      }
    end

    def sale
      @sale ||= @transaction.transaction
    end

    def card
      @card ||= @sale.credit_card_details
    end

    def customer
      @customer ||= @sale.customer_details
    end
  end
end


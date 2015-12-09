module Payment
  class << self
    def table_name_prefix
      'payment_'
    end

    def write_transaction(transaction:, provider: :braintree)
      BraintreeTransactionBuilder.build(transaction)
    end

    def write_subscription(subscription:, provider: :braintree)
      BraintreeSubscriptionBuilder.build(subscription)
    end

    def customer(email)
      Payment::BraintreeCustomer.find_by(email: email)
    end
  end

  class BraintreeSubscriptionBuilder

    def self.build(response)
      new(response).build
    end

    def initialize(response)
      @response = response
      @subscription = response.subscription
    end

    def build
      if @response.success?
        ::Payment::BraintreeSubscription.create(attrs)
      end
    end

    def attrs
     {
        subscription_id:        @subscription.id,
        price:                  @subscription.price,
        merchant_account_id:    @subscription.merchant_account_id
      }
    end
  end

  class BraintreeTransactionBuilder

    def self.build(transaction)
      new(transaction).build
    end

    def initialize(transaction)
      @transaction = transaction
    end

    def build
      if @transaction.success?
        ::Payment::BraintreeTransaction.create(transaction_attrs)

        unless customer
          ::Payment::BraintreeCustomer.create(customer_attrs)
        end
      end
    end

    private

    def customer
      @customer ||= Payment.customer(customer_details.email)
    end

    def transaction_attrs
     {
        transaction_id:         sale.id,
        transaction_type:       sale.type,
        amount:                 sale.amount,
        transaction_created_at: sale.created_at,
        merchant_account_id:    sale.merchant_account_id,
        currency:               sale.currency_iso_code
      }
    end

    def customer_attrs
      {
        card_type:        card.card_type,
        card_bin:         card.bin,
        cardholder_name:  card.cardholder_name,
        card_debit:       card.debit,
        card_last_4:      card.last_4,
        default_payment_method_token: card.token,
        email:            customer_details.email,
        first_name:       customer_details.first_name,
        last_name:        customer_details.last_name,
        customer_id:      customer_details.id
      }
    end

    def sale
      @sale ||= @transaction.transaction
    end

    def card
      @card ||= @sale.credit_card_details
    end

    def customer_details
      @customer ||= @sale.customer_details
    end
  end
end


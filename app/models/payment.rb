module Payment
  class << self
    def table_name_prefix
      'payment_'
    end

    def write_successful_transaction(page:, transaction:, provider: :braintree)
      BraintreeTransactionBuilder.build(page, transaction)
    end

    def write_unsuccessful_transaction(page:, transaction:, provider: :braintree)
      # TODO: Implement
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

    def self.build(page, transaction)
      new(page, transaction).build
    end

    def initialize(page, transaction)
      @page = page
      @transaction = transaction
    end

    def build
      if @transaction.success?
        ::Payment::BraintreeTransaction.create(transaction_attrs)
        unless customer
          new_customer = ::Payment::BraintreeCustomer.create(customer_attrs)
          new_customer.member = Member.find_or_initialize_by(email: new_customer.email)
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
        currency:               sale.currency_iso_code,
        page:                   @page
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
        customer_id:      customer_details.id,
        email:            customer_details.email
      }
    end

    def sale
      @transaction.transaction
    end

    def card
      @sale.credit_card_details
    end

    def customer_details
      @sale.customer_details
    end
  end
end


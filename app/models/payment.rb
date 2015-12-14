module Payment
  class << self
    def table_name_prefix
      'payment_'
    end

    def write_successful_transaction(action:, transaction:)
      BraintreeTransactionBuilder.build(action, transaction)
    end

    def write_unsuccessful_transaction(action:, transaction:)
      # TODO: Implement
    end

    def write_subscription(subscription:)
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
    # = BraintreeTransactionBuilder
    #
    # Stores and associates a Braintree transaction as +Payment::BraintreeTransaction+. Builder will also
    # create an instance of +Payment::BraintreeCustomer+, if it doesn't already exist.
    #
    # === Options
    #
    # * +:action+        - The ActiveRecord model of the corresponding action.
    # * +:transaction+   - An Braintree::Transaction response object (see https://developers.braintreepayments.com/reference/response/transaction/ruby)
    #

    def self.build(action, transaction)
      new(action, transaction).build
    end

    def initialize(action, transaction)
      @action = action
      @transaction = transaction
    end


    def build
      if @transaction.success?
        ::Payment::BraintreeTransaction.create(transaction_attrs)

        unless locally_stored_customer
          store_braintree_customer_locally
        end
      end
    end

    private

    def locally_stored_customer
      @locally_stored_customer ||= Payment.customer(customer_details.email)
    end

    def store_braintree_customer_locally
      Payment::BraintreeCustomer.create(customer_attrs)
    end

    def transaction_attrs
     {
        transaction_id:         sale.id,
        transaction_type:       sale.type,
        amount:                 sale.amount,
        transaction_created_at: sale.created_at,
        merchant_account_id:    sale.merchant_account_id,
        currency:               sale.currency_iso_code,
        page:                   @action.page
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
        email:            customer_details.email,
        member:           @action.member
      }
    end

    def sale
      @transaction.transaction
    end

    def card
      sale.credit_card_details
    end

    def customer_details
      sale.customer_details
    end
  end
end


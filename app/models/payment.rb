module Payment
  class << self
    def table_name_prefix
      'payment_'
    end

    def write_successful_transaction(action:, transaction_response:)
      BraintreeTransactionBuilder.build(action, transaction_response)
    end

    def write_unsuccessful_transaction(action:, transaction_response:)
      # TODO: Implement
    end

    def write_subscription(subscription:)
      BraintreeSubscriptionBuilder.build(subscription)
    end

    def customer(email)
      member = Member.find_by(email: email)
      member.try(:customer)
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
    #
    # Stores and associates a Braintree transaction as +Payment::BraintreeTransaction+. Builder will also
    # create an instance of +Payment::BraintreeCustomer+, if it doesn't already exist.
    #
    # === Options
    #
    # * +:action+                 - The ActiveRecord model of the corresponding action.
    # * +:transaction_response+   - An Braintree::Transaction response object (see https://developers.braintreepayments.com/reference/response/transaction/ruby)
    #

    def self.build(action, transaction_response)
      new(action, transaction_response).build
    end

    def initialize(action, transaction_response)
      @action = action
      @transaction_response = transaction_response
    end


    def build
      if @transaction_response.success?
        ::Payment::BraintreeTransaction.create(transaction_attrs)

        if locally_stored_customer
          locally_stored_customer.update(customer_attrs)
        else
          store_braintree_customer_locally
        end
      end
    end

    private

    def locally_stored_customer
      @locally_stored_customer ||= Payment.customer(transaction.customer_details.email)
    end

    def store_braintree_customer_locally
      Payment::BraintreeCustomer.create(customer_attrs)
    end

    def transaction_attrs
      {
        transaction_id:          transaction.id,
        transaction_type:        transaction.type,
        payment_instrument_type: transaction.payment_instrument_type,
        amount:                  transaction.amount,
        transaction_created_at:  transaction.created_at,
        merchant_account_id:     transaction.merchant_account_id,
        currency:                transaction.currency_iso_code,
        customer_id:             transaction.customer_details.id,
        status:                  status,
        payment_method_token:    payment_method_token,
        page:                    @action.page
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
        customer_id:      transaction.customer_details.id,
        member:           @action.member
      }
    end

    def transaction
      @transaction_response.transaction
    end

    def card
      transaction.credit_card_details
    end

    def status
      if @transaction_response.success?
        Payment::BraintreeTransaction.statuses[:success]
      else
        Payment::BraintreeTransaction.statuses[:failure]
      end
    end

    def payment_method_token
      case transaction.payment_instrument_type
      when "credit_card"
        transaction.credit_card_details.try(:token)
      when "paypal_account"
        transaction.paypal_details.try(:token)
      else
        nil
      end
    end
  end
end


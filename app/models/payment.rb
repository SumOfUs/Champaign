module Payment
  class << self
    def table_name_prefix
      'payment_'
    end

    def write_transaction(bt_result, page_id, member_id)
      BraintreeTransactionBuilder.build(bt_result, page_id, member_id)
    end

    def write_subscription(subscription_result, page_id, currency)
      if subscription_result.success?
        Payment::BraintreeSubscription.create({
          subscription_id:        subscription_result.subscription.id,
          amount:                 subscription_result.subscription.price,
          merchant_account_id:    subscription_result.subscription.merchant_account_id,
          currency:               currency,
          page_id:                page_id
        })
      end
    end

    def write_customer(bt_customer, bt_payment_method, member_id, existing_customer)
      BraintreeCustomerBuilder.build(bt_customer, bt_payment_method, member_id, existing_customer)
    end

    def customer(email)
      customer = Payment::BraintreeCustomer.find_by(email: email)
      return customer if customer.present?
      member = Member.find_by(email: email)
      member.try(:customer)
    end
  end

  class BraintreeCustomerBuilder
    def self.build(bt_customer, bt_payment_method, member_id, existing_customer)
      new(bt_customer, bt_payment_method, member_id, existing_customer).build
    end

    def initialize(bt_customer, bt_payment_method, member_id, existing_customer)
      @bt_customer = bt_customer
      @bt_payment_method = bt_payment_method
      @existing_customer = existing_customer
      @member_id = member_id
    end

    def build
      if @existing_customer.present?
        @existing_customer.update(customer_attrs)
      else
        Payment::BraintreeCustomer.create(customer_attrs)
      end
    end

    def customer_attrs
      card_attrs.merge({
        card_vault_token: @bt_payment_method.token,
        customer_id:      @bt_customer.id,
        member_id:        @member_id
      })
    end

    def card_attrs
      if @bt_payment_method.class == Braintree::CreditCard
        {
          card_type:        @bt_payment_method.card_type,
          card_bin:         @bt_payment_method.bin,
          cardholder_name:  @bt_payment_method.cardholder_name,
          card_debit:       @bt_payment_method.debit,
          card_last_4:      @bt_payment_method.last_4
        }
      else
        {
          card_last_4: 'PYPL' # for now, assume PayPal if not CC
        }
      end
    end
  end

  class BraintreeTransactionBuilder
    #
    # Stores and associates a Braintree transaction as +Payment::BraintreeTransaction+. Builder will also
    # create an instance of +Payment::BraintreeCustomer+, if it doesn't already exist.
    #
    # === Options
    #
    # * +:action+      - The ActiveRecord model of the corresponding action.
    # * +:bt_result+   - A Braintree::Transaction response object or a Braintree::Subscription response
    #                    (see https://developers.braintreepayments.com/reference/response/transaction/ruby)
    #
    #

    def self.build(bt_result, page_id, member_id)
      new(bt_result, page_id, member_id).build
    end

    def initialize(bt_result, page_id, member_id)
      @bt_result = bt_result
      @page_id = page_id
      @member_id = member_id
    end

    def build
      ::Payment::BraintreeTransaction.create(transaction_attrs)
      return unless @bt_result.success?

      # it would be good to DRY this up and use CustomerBuilder, but we don't
      # have a Braintree::PaymentMethod to pass it :(
      if existing_customer.present?
        existing_customer.update(customer_attrs)
      else
        Payment::BraintreeCustomer.create(customer_attrs)
      end
    end

    private

    def existing_customer
      @existing_customer ||= Payment.customer(transaction.customer_details.email)
    end

    def transaction_attrs
      {
        transaction_id:          transaction.id,
        transaction_type:        transaction.type,
        payment_instrument_type: transaction.payment_instrument_type,
        amount:                  transaction.amount,
        transaction_created_at:  transaction.created_at,
        merchant_account_id:     transaction.merchant_account_id,
        processor_response_code: transaction.processor_response_code,
        currency:                transaction.currency_iso_code,
        customer_id:             transaction.customer_details.id,
        status:                  status,
        payment_method_token:    payment_method_token,
        page_id:                 @page_id
      }
    end

    def customer_attrs
      {
        card_type:        card.card_type,
        card_bin:         card.bin,
        cardholder_name:  card.cardholder_name,
        card_debit:       card.debit,
        card_last_4:      last_4,
        card_vault_token: payment_method_token,
        customer_id:      transaction.customer_details.id,
        member_id:        @member_id
      }
    end

    def transaction
      @bt_result.transaction || @bt_result.subscription.transactions.first
    end

    def card
      transaction.credit_card_details
    end

    def status
      if @bt_result.success?
        Payment::BraintreeTransaction.statuses[:success]
      else
        Payment::BraintreeTransaction.statuses[:failure]
      end
    end

    def last_4
      transaction.payment_instrument_type == "paypal_account" ? 'PYPL' : card.last_4
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


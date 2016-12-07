# frozen_string_literal: true
module Payment::Braintree
  class << self
    def table_name_prefix
      'payment_braintree_'
    end

    # TODO: Why don't we have an options hash at the end?
    # def write_transaction(bt_result, page, member_id, existing_customer, options = {})
    def write_transaction(bt_result, page, member_id, existing_customer, save_customer = true, store_in_vault: false)
      BraintreeTransactionBuilder.build(bt_result, page, member_id, existing_customer, save_customer, store_in_vault: store_in_vault)
    end

    def write_subscription(payment_method_id, customer_id, subscription_result, page_id, action_id, currency)
      if subscription_result.success?
        Payment::Braintree::Subscription.create(payment_method_id:      payment_method_id,
                                                customer_id:            customer_id,
                                                subscription_id:        subscription_result.subscription.id,
                                                amount:                 subscription_result.subscription.price,
                                                merchant_account_id:    subscription_result.subscription.merchant_account_id,
                                                billing_day_of_month:   subscription_result.subscription.billing_day_of_month,
                                                action_id:              action_id,
                                                currency:               currency,
                                                page_id:                page_id)
      end
    end

    def write_customer(bt_customer, bt_payment_method, member_id, existing_customer)
      BraintreeCustomerBuilder.build(bt_customer, bt_payment_method, member_id, existing_customer)
    end

    def customer(email)
      member = Member.find_by_email(email)
      member.try(:customer)
    end
  end

  class BraintreeCustomerBuilder
    def self.build(bt_customer, bt_payment_method, member_id, existing_customer, store_in_vault: false)
      new(bt_customer, bt_payment_method, member_id, existing_customer, store_in_vault).build
    end

    def initialize(bt_customer, bt_payment_method, member_id, existing_customer, store_in_vault)
      @bt_customer = bt_customer
      @customer = existing_customer
      @member_id = member_id
      @bt_payment_method = bt_payment_method
      @store_in_vault = store_in_vault
    end

    def build
      if @customer.present?
        @customer.update(customer_attrs)
      else
        @customer = Payment::Braintree::Customer.create(customer_attrs)
      end

      payment_method = Payment::Braintree::PaymentMethod.find_or_create_by!(token:  @bt_payment_method.token) do |pm|
        pm.customer = @customer
        pm.store_in_vault = @store_in_vault
      end

      case @bt_payment_method
      when Braintree::PayPalAccount
        payment_method.update(email: @bt_payment_method.email,
                              instrument_type: 'paypal_account')
      when Braintree::CreditCard
        payment_method.update(instrument_type: 'credit_card',
                              last_4: @bt_payment_method.last_4,
                              bin: @bt_payment_method.bin,
                              expiration_date: @bt_payment_method.expiration_date,
                              card_type: @bt_payment_method.card_type,
                              cardholder_name: @bt_payment_method.cardholder_name)
      end

      @customer
    end

    def customer_attrs
      card_attrs.merge(customer_id:      @bt_customer.id,
                       member_id:        @member_id,
                       email:            @bt_customer.email)
    end

    def card_attrs
      if @bt_payment_method.is_a? Braintree::CreditCard
        @bt_payment_method.instance_eval do
          {
            card_type:        card_type,
            card_bin:         bin,
            cardholder_name:  cardholder_name,
            card_debit:       debit,
            card_last_4:      last_4,
            card_unique_number_identifier: unique_number_identifier
          }
        end
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
    # create or update an instance of +Payment::BraintreeCustomer+, if save_customer is passed
    #
    # === Options
    #
    # * +:bt_result+   - A Braintree::Transaction response object or a Braintree::Subscription response
    #                    (see https://developers.braintreepayments.com/reference/response/transaction/ruby)
    #                    or a Braintree::WebhookNotification
    # * +:page+        - the Page to associate with the transaction record
    # * +:member_id+   - the member_id to associate with the customer record
    # * +:existing_customer+ - if passed, this customer is updated instead of creating a new one
    # * +:save_customer+     - optional, default true. whether to save the customer info too
    #
    #

    def self.build(bt_result, page, member_id, existing_customer, save_customer = true, store_in_vault = false)
      new(bt_result, page, member_id, existing_customer, save_customer, store_in_vault).build
    end

    def initialize(bt_result, page, member_id, existing_customer, save_customer = true, store_in_vault: false)
      @bt_result = bt_result
      @page = page
      @member_id = member_id
      @existing_customer = existing_customer
      @save_customer = save_customer
      @store_in_vault = store_in_vault
    end

    # NOTE this method has all the looks of a service:
    #  - create_customer
    #  - create_payment_method
    #  - create_transactions
    def build
      return unless transaction.present?

      create_customer
      create_payment_method
      record = create_transaction
      return false unless successful?
      @customer.update(customer_attrs) if @save_customer && @customer
      record
    end

    private

    def create_customer
      if transaction.customer_details.id
        @customer = @existing_customer || Payment::Braintree::Customer.find_or_create_by!(
          member_id: @member_id,
          customer_id: transaction.customer_details.id
        )
      end
    end

    def create_payment_method
      if payment_method_token.nil? || @bt_result.transaction.nil?
        @local_payment_method_id = nil
      else
        @local_payment_method_id = BraintreeServices::PaymentMethodBuilder.new(
          transaction: @bt_result.transaction,
          customer: @customer,
          store_in_vault: @store_in_vault
        ).create.id
      end
    end

    def create_transaction
      ::Payment::Braintree::Transaction.create!(transaction_attrs)
    end

    def transaction_attrs
      {
        transaction_id:                  transaction.id,
        transaction_type:                transaction.type,
        payment_instrument_type:         transaction.payment_instrument_type,
        amount:                          transaction.amount,
        transaction_created_at:          transaction.created_at,
        merchant_account_id:             transaction.merchant_account_id,
        processor_response_code:         transaction.processor_response_code,
        currency:                        transaction.currency_iso_code,
        customer_id:                     @customer.try(:customer_id),
        status:                          status,
        payment_method_id:               @local_payment_method_id,
        page:                            @page,
        pledge:                          @page.pledger?
      }.tap do |data|
        if transaction.try(:subscription_id)
          data[:subscription] = Payment::Braintree::Subscription.find_by_subscription_id(transaction.subscription_id)
        end
      end
    end

    def customer_attrs
      {
        # NOTE: we do NOT store card_unique_number_identifier because
        # that is only returned on Braintree::CreditCard, not on
        # Braintree::Transaction::CreditCardDetails
        card_type:                 card.card_type,
        card_bin:                  card.bin,
        cardholder_name:           card.cardholder_name,
        card_debit:                card.debit,
        card_last_4:               last_4,
        customer_id:               transaction.customer_details.id,
        email:                     transaction.customer_details.email,
        member_id:                 @member_id
      }
    end

    def transaction
      @bt_result.try(:transaction) || @bt_result.try(:subscription).try(:transactions).try(:first)
    end

    def card
      transaction.credit_card_details
    end

    def status
      Payment::Braintree::Transaction.statuses[(successful? ? :success : :failure)]
    end

    def successful?
      return @bt_result.success? if @bt_result.respond_to?(:success?)
      if @bt_result.is_a?(Braintree::WebhookNotification) && @bt_result.kind == 'subscription_charged_successfully'
        return true
      end
      false
    end

    def last_4
      transaction.payment_instrument_type == 'paypal_account' ? 'PYPL' : card.last_4
    end

    def payment_method_token
      case transaction.payment_instrument_type
      when 'credit_card'
        transaction.credit_card_details.try(:token)
      when 'paypal_account'
        transaction.paypal_details.try(:token)
      end
    end
  end
end

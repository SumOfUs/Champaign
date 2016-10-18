# frozen_string_literal: true
module BraintreeServices
  class PaymentMethodBuilder
    def initialize(transaction:, customer: nil, store_in_vault: false)
      @transaction = transaction
      @customer = customer
      @store_in_vault = store_in_vault
    end

    def create
      Payment::Braintree::PaymentMethod.find_by(token: attributes['token']) ||
        Payment::Braintree::PaymentMethod.create(attributes)
    end

    private

    def attributes
      case @transaction.payment_instrument_type
      when Braintree::PaymentInstrumentType::CreditCard
        attrs = credit_card_attributes
      when Braintree::PaymentInstrumentType::PayPalAccount
        attrs = paypal_attributes
      end

      attrs.merge(store_in_vault: @store_in_vault)
    end

    def credit_card_attributes
      %w(last_4 card_type expiration_date bin token).each_with_object({}) do |attr, attributes|
        attributes[attr] = @transaction.credit_card_details.send(attr)
      end.merge(
        customer: @customer,
        instrument_type: 'credit_card'
      )
    end

    def paypal_attributes
      {
        token: @transaction.paypal_details.token,
        email: @transaction.paypal_details.payer_email,
        customer: @customer,
        instrument_type: 'paypal_account'
      }
    end
  end
end

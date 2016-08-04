module BraintreeServices
  class PaymentMethodBuilder
    def initialize(transaction:, customer: nil)
      @transaction = transaction
      @customer = customer
    end

    def create
      Payment::Braintree::PaymentMethod.find_by(token: attributes['token']) ||
        Payment::Braintree::PaymentMethod.create(attributes)
    end

    private

    def attributes
      case @transaction.payment_instrument_type
      when Braintree::PaymentInstrumentType::CreditCard
        credit_card_attributes
      when Braintree::PaymentInstrumentType::PayPalAccount
        paypal_attributes
      end
    end

    def credit_card_attributes
      %w{last_4 card_type expiration_date bin token}.inject({}) do |attributes, attr|
        attributes[attr] = @transaction.credit_card_details.send(attr)
        attributes
      end.merge({
        customer: @customer,
        instrument_type: 'credit_card'
      })
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

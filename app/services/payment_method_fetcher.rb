# frozen_string_literal: true

class PaymentMethodFetcher
  def initialize(member, filter: [])
    @member = member
    @filter = filter
  end

  def fetch
    return [] unless @member && @member.customer

    tokens = if @filter.any?
               @member.customer.payment_methods.where(token: @filter)
             else
               @member.customer.payment_methods.stored
             end

    tokens.map do |m|
      {
        id: m.id,
        last_4: m.last_4,
        instrument_type: m.instrument_type,
        card_type: m.card_type,
        email: m.email,
        token: m.token
      }
    end
  end
end

# frozen_string_literal: true

class PaymentMethodFetcher
  def initialize(member, filter: nil)
    @member = member
    @filter = filter
  end

  def fetch
    return [] unless customer?
    return [] if empty_filter?

    payment_methods.map do |m|
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

  private

  def customer?
    @member && @member.customer.present?
  end

  def empty_filter?
    !@filter.nil? && @filter.empty?
  end

  def payment_methods
    return @payment_methods if @payment_methods

    query = @member.customer.payment_methods.stored.active
    query = query.where(token: @filter) unless @filter.nil?

    @payment_methods = query
  end
end

# frozen_string_literal: true

module PaymentProcessor::Braintree
  class OneClickFromUri
    attr_reader :params, :page, :member, :cookied_payment_methods

    def initialize(params, page:, member: nil, cookied_payment_methods: '')
      @params = params
      @page = page
      @member = member
      @cookied_payment_methods = cookied_payment_methods
    end

    def process
      return false unless one_click?

      PaymentProcessor::Braintree::OneClick.new(options).run
      true
    end

    private

    def one_click?
      params.fetch(:one_click, '') == 'true' &&
        payment_method_id &&
        params.fetch(:amount, 0).to_f > 0 &&
        params[:currency].present?
    end

    def options
      ActionController::Parameters.new(
        payment: {
          payment_method_id: payment_method_id,
          currency: params[:currency],
          amount: params[:amount]
        },
        user: {
          email: member.email
        },
        page_id: page.id
      )
    end

    def payment_method_id
      if member
        member.customer.payment_methods.first.id
      else
        Payment::Braintree::PaymentMethod.find_by(token: token_from_cookie)
      end
    end

    def token_from_cookie
      (cookied_payment_methods || '').split(',').first
    end
  end
end

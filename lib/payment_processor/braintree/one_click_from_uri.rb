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
      self
    end

    def recurring?
      Plugins::Fundraiser.donation_default_for_page(page.id) ||
        ActiveRecord::Type::Boolean.new.type_cast_from_user(params[:recurring])
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
          amount: params[:amount],
          recurring: recurring?
        },
        user: {
          email: member.email
        },
        page_id: page.id
      )
    end

    def payment_method_id
      if member.try(:customer)
        member.customer.payment_methods.stored.first.try(:id)
      else
        Payment::Braintree::PaymentMethod.find_by(token: token_from_cookie)
      end
    end

    def token_from_cookie
      (cookied_payment_methods || '').split(',').first
    end
  end
end

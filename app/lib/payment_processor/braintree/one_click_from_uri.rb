# frozen_string_literal: true

module PaymentProcessor::Braintree
  class OneClickFromUri
    attr_reader :params, :page, :member, :cookied_payment_methods

    def initialize(params, page:, member: nil, cookied_payment_methods: '')
      @params = params.symbolize_keys
      @page = page
      @member = member
      @cookied_payment_methods = cookied_payment_methods || ''
    end

    def process
      raise ArgumentError, 'Invalid request arguments' unless one_click?

      PaymentProcessor::Braintree::OneClick.new(options, @cookied_payment_methods, member).run
      self
    end

    def recurring?
      Plugins::Fundraiser.donation_default_for_page(page.id) ||
        %w[recurring only_recurring].include?(params[:recurring_default])
    end

    private

    def one_click_flag
      ActiveRecord::Type::Boolean.new.cast(
        params.fetch(:one_click, false)
      )
    end

    def positive_amount?
      params.fetch(:amount, 0).to_f.positive?
    end

    def currency_present?
      params[:currency].present?
    end

    def one_click?
      Rails.logger.info("one_click_flag is: #{one_click_flag}")
      Rails.logger.info("payment_method_id is: #{payment_method_id}")
      Rails.logger.info("positive_amount is: #{positive_amount}")
      Rails.logger.info("currency_present is: #{currency_present}")
      @one_click ||= one_click_flag &&
                     payment_method_id &&
                     positive_amount? &&
                     currency_present?
      @one_click
    end

    def options
      {
        payment: {
          payment_method_id: payment_method_id,
          currency: params[:currency],
          amount: params[:amount],
          recurring: recurring?
        },
        user: {
          akid: params[:akid],
          email: member.email
        },
        page_id: page.id
      }.with_indifferent_access
    end

    def payment_method_id
      customer = member&.customer
      Rails.logger.info("Customer on payment_method_id is: #{customer}")
      return nil unless customer

      customer.valid_payment_method_id(cookied_payment_methods.split(','))
    end

    def token_from_cookie
      (cookied_payment_methods || '').split(',').first
    end
  end
end

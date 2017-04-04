# frozen_string_literal: true

module PaymentProcessor::Braintree
  class OneClickFromUri
    attr_reader :params, :page, :member, :cookied_payment_methods

    def initialize(params, page:, member: nil, cookied_payment_methods: '')
      @params = params
      @page = page
      @member = member
      @cookied_payment_methods = cookied_payment_methods || ''
    end

    def process
      return false unless one_click?
      PaymentProcessor::Braintree::OneClick.new(options).run
      self
    end

    def recurring?
      Plugins::Fundraiser.donation_default_for_page(page.id) ||
        %w(recurring only_recurring).include?(params[:recurring_default])
    end

    private

    def one_click?
      params.fetch(:one_click, '') == 'true' &&
        payment_method_id &&
        params.fetch(:amount, 0).to_f.positive? &&
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
          akid: params[:akid],
          email: member.email
        },
        page_id: page.id
      )
    end

    def payment_method_id
      cookied_payment_methods.split(',').each do |token|
        pm = member.customer.payment_methods.find_by(token: token, cancelled_at: nil, store_in_vault: true)
        if pm && pm.expiration_date.to_date > Date.today
          return pm.id
        end
      end

      false
    end

    def token_from_cookie
      (cookied_payment_methods || '').split(',').first
    end
  end
end

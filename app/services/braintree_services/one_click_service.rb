# frozen_string_literal: true

module BraintreeServices
  class OneClickService
    attr_reader :params, :payment_options

    def initialize(params)
      @params = params
      @payment_options = BraintreeServices::PaymentOptions.new(params)
    end

    def run
      create_action

      if payment_options.recurring?
        sale = make_subscription
        store_subscription_locally(sale) if sale.success?
      else
        sale = make_sale
        store_sale_locally(sale) if sale.success?
      end
    end

    private

    def create_action
      action = ManageAction.create(
        params_for_action,
        skip_counter: true,
        skip_queue: false
      )

      action.update(donation: true)
    end

    def params_for_action
      ActionParamsBuilder.new(self, DonationActionParamsWrapper.params(params)).action_params
    end

    def make_sale
      @make_sale ||= ::Braintree::Transaction.sale(
        payment_method_token: payment_options.token,
        amount: payment_options.amount
      )
    end

    def make_subscription
      @make_subscription ||= ::Braintree::Subscription.create(payment_options.subscription_options)
    end

    def store_sale_locally(sale)
      TransactionBuilder.new(sale.transaction, payment_options).build
    end

    def store_subscription_locally(sale)
      SubscriptionBuilder.new(sale.subscription, payment_options).build
    end
  end
end

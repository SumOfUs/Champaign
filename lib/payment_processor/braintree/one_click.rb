# frozen_string_literal: true

module PaymentProcessor::Braintree
  class OneClick
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

    def create_action(_extra = {})
      ManageAction.create(
        params_for_action.merge(params[:user])
          .merge(params[:payment])
          .merge(page_id: params[:page_id])
          .merge(action_express_donation: 1,
                 store_in_vault: true,
                 express_account: payment_options.express_account?,
                 card_num: payment_options.payment_method.last_4,
                 card_expiration_date: payment_options.payment_method.expiration_date),
        extra_params: { donation: true },
        skip_counter: true,
        skip_queue: false
      )
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
      BraintreeServices::TransactionBuilder.new(sale.transaction, payment_options).build
    end

    def store_subscription_locally(sale)
      BraintreeServices::SubscriptionBuilder.new(sale.subscription, payment_options).build
    end
  end
end

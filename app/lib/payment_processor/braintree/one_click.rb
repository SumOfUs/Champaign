# frozen_string_literal: true

module PaymentProcessor::Braintree
  class OneClick
    attr_reader :params, :payment_options

    def initialize(params, cookied_payment_methods, member = nil)
      @params = params
      @payment_options = BraintreeServices::PaymentOptions.new(params, cookied_payment_methods)
      @member = member
    end

    def run
      raise PaymentProcessor::Exceptions::CustomerNotFound unless @member.try(:customer)

      # TODO: On the second attempt (if the member consents to duplicate donation), post with the same parameters
      # but also params[:allow_duplicate] = true
      return duplicate_donation_error_response if duplicate_donation && !payment_options.params[:allow_duplicate]

      sale = make_payment
      if sale.success?
        action = create_action(extra_fields(sale))
        store_locally(sale, action)
      end

      sale
    end

    def duplicate_donation
      resources = (payment_options.recurring? ? 'subscriptions' : 'transactions')
      # Check if there are any transactions/subscriptions for the customer,
      # within 10 minutes, with the same amount
      !@member.customer.send(resources)
        .where('created_at > ? AND amount = ? AND page_id = ?',
               10.minutes.ago, payment_options.params[:payment][:amount], params[:page_id])
        .empty?
    end

    def duplicate_donation_error_response
      error = DuplicateDonationError.new
      DuplicateDonationResponse.new(errors: [error], message: error.message, params: @params)
    end

    def extra_fields(sale)
      if payment_options.recurring?
        return {
          is_subscription: true,
          subscription_id: sale.subscription.id,
          transaction_id: sale.subscription.transactions.last.id
        }
      end
      { transaction_id: sale.transaction.id }
    end

    private

    def make_payment
      if payment_options.recurring?
        make_subscription
      else
        make_sale
      end
    end

    def store_locally(sale, action = nil)
      if payment_options.recurring?
        store_subscription_locally(sale, action)
      else
        store_sale_locally(sale)
      end
    end

    def create_action(extra = {})
      ManageAction.create(
        params_for_action.merge(params[:user])
          .merge(extra)
          .merge(params[:payment])
          .merge(page_id: params[:page_id])
          .merge(action_express_donation: 1,
                 store_in_vault: true,
                 is_recurring: payment_options.recurring?,
                 express_account: payment_options.express_account?,
                 card_num: payment_options.last_4,
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
        amount: payment_options.amount,
        merchant_account_id: payment_options.merchant_account_id,
        options: {
          submit_for_settlement: true
        }
      )
    end

    def make_subscription
      @make_subscription ||= ::Braintree::Subscription.create(payment_options.subscription_options)
    end

    def store_sale_locally(sale)
      BraintreeServices::TransactionBuilder.new(sale.transaction, payment_options).build
    end

    def store_subscription_locally(sale, action = nil)
      BraintreeServices::SubscriptionBuilder.new(sale.subscription, payment_options, action).build
    end
  end
end

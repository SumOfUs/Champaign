# frozen_string_literal: true

class ActionParamsBuilder
  attr_reader :controller, :params

  delegate :browser, :request, to: :controller

  def initialize(controller, params)
    @controller = controller
    @params = params
  end

  def action_params
    build_params
  end

  private

  def mobile_value
    MobileDetector.detect(browser)
  end

  def referer_url
    { action_referer: request.referer }
  end

  def build_params
    params.permit(fields + base_params).merge(donation: true)
  end

  def base_params
    %w(page_id form_id name source akid referring_akid email)
  end

  def fields
    Form.find(params[:form_id]).form_elements.map(&:name)
  end
end

class BraintreeSubscriptionBuilder
  attr_reader :subscription, :payment_options

  def initialize(subscription, payment_options)
    @subscription = subscription
    @payment_options = payment_options
  end

  def build
    Payment::Braintree::Subscription.create!(attributes)
  end

  def attributes
    {
      subscription_id: subscription.id,
      payment_method: payment_options.payment_method,
      amount: payment_options.amount,
      merchant_account_id: payment_options.merchant_account_id,
      customer: payment_options.customer,
      currency: payment_options.currency,
      billing_day_of_month: subscription.billing_day_of_month,
      page_id: payment_options.page.id
    }
  end
end

class BraintreeTransactionBuilder
  attr_reader :payment_options, :transaction

  def initialize(transaction, payment_options)
    @payment_options = payment_options
    @transaction = transaction
  end

  def build
    Payment::Braintree::Transaction.create!(attributes)
  end

  private

  def attributes
    {
      amount:                          transaction.amount,
      currency:                        transaction.currency_iso_code,
      customer_id:                     payment_options.customer.customer_id,
      payment_method:                  payment_options.payment_method,
      transaction_id:                  transaction.id,
      transaction_type:                transaction.type,
      merchant_account_id:             transaction.merchant_account_id,
      transaction_created_at:          transaction.created_at,
      payment_instrument_type:         transaction.payment_instrument_type,
      processor_response_code:         transaction.processor_response_code,
      page_id:                         payment_options.page.id
    }
  end
end

class DonationActionParamsWrapper
  def self.params(params)
    new(params).params
  end

  def initialize(params)
    @params = params
  end

  def params
    @params[:user].merge(
      page_id: @params[:page_id]
    )
  end
end

module Json
  class BraintreeCreditCard
    def initialize(card)
      @card = card
    end

    def to_builder
      Jbuilder.new do |json|
        json.call(@card, :token)
      end
    end
  end

  class BraintreeTransaction
    def initialize(transaction, member)
      @transaction = transaction
      @member = member
    end

    def to_builder
      Jbuilder.new do |json|
        json.order do
          card = @transaction.credit_card_details
          month, year = card.expiration_date.split('/')

          json.amount         @transaction.amount.to_s
          json.card_num       card.last_4
          json.card_code      '007'
          json.exp_date_month month
          json.exp_date_year  year
          json.currency       @transaction.currency_iso_code
        end
      end
    end
  end
end

class PaymentOptions
  attr_reader :params

  def initialize(params)
    @params = params
  end

  def payment_method
    @payment_method ||= customer.payment_methods.find(params[:payment][:payment_method_id])
  end

  def amount
    params[:payment][:amount]
  end

  def token
    payment_method.token
  end

  def merchant_account_id
    PaymentProcessor::Braintree::MerchantAccountSelector
      .for_currency(params[:payment][:currency])
  end

  def plan_id
    PaymentProcessor::Braintree::SubscriptionPlanSelector
      .for_currency(params[:payment][:currency])
  end

  def currency
    params[:payment][:currency]
  end

  def customer
    @customer ||= member.braintree_customer
  end

  def member
    Member.find_by(email: params[:user][:email])
  end

  def page
    @page = Page.find(params[:page_id])
  end

  def subscription_options
    {
      payment_method_token: token,
      plan_id: plan_id,
      price: amount,
      merchant_account_id: merchant_account_id
    }
  end

  def recurring?
    ActiveRecord::Type::Boolean.new.type_cast_from_user(params[:payment][:recurring])
  end
end

class BraintreeOneClickService
  attr_reader :params, :payment_options

  def initialize(params)
    @params = params
    @payment_options = PaymentOptions.new(params)
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
    BraintreeTransactionBuilder.new(sale.transaction, payment_options).build
  end

  def store_subscription_locally(sale)
    BraintreeSubscriptionBuilder.new(sale.subscription, payment_options).build
  end
end

class Api::Payment::BraintreeController < PaymentController
  skip_before_action :verify_authenticity_token

  def token
    render json: { token: ::Braintree::ClientToken.generate }
  end

  def webhook
    if client::WebhookHandler.handle(params[:bt_signature], params[:bt_payload])
      head :ok
    else
      head :not_found
    end
  end

  def one_click
    BraintreeOneClickService.new(params).run
    render json: { success: true }
  end

  private

  def payment_options
    {
      nonce: params[:payment_method_nonce],
      amount: params[:amount].to_f,
      user: params[:user].merge(mobile_value),
      currency: params[:currency],
      page_id: params[:page_id]
    }
  end

  def transaction_options
    boolean_type = ActiveRecord::Type::Boolean.new
    payment_options.merge(
      store_in_vault: boolean_type.type_cast_from_user(params[:store_in_vault]) || false
    )
  end

  def client
    PaymentProcessor::Braintree
  end

  def page
    @page ||= Page.find(params[:page_id])
  end

  def recurring?
    @recurring ||= ActiveRecord::Type::Boolean.new.type_cast_from_user(params[:recurring])
  end
end

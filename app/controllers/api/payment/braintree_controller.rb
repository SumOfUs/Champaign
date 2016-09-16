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

class BraintreeTransactionBuilder
  attr_reader :customer, :transaction

  def initialize(transaction, customer)
    @transaction = transaction
    @customer = customer
  end

  def build
    Payment::Braintree::Transaction.create!(attributes)
  end

  private

  def attributes
    {
      amount:                          transaction.amount,
      currency:                        transaction.currency_iso_code,
      customer_id:                     customer.customer_id,
      payment_method:                  customer.default_payment_method,
      transaction_id:                  transaction.id,
      transaction_type:                transaction.type,
      merchant_account_id:             transaction.merchant_account_id,
      transaction_created_at:          transaction.created_at,
      payment_instrument_type:         transaction.payment_instrument_type,
      processor_response_code:         transaction.processor_response_code
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

class BraintreeOneClickService
  attr_reader :params

  def initialize(params)
    @params = params
  end

  def run
    create_action
    sale = make_sale

    store_sale_locally(sale) if sale.success?
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
      payment_method_token: customer.default_payment_method.token,
      amount: params[:payment][:amount]
    )
  end

  def store_sale_locally(sale)
    BraintreeTransactionBuilder.new(sale.transaction, customer).build
  end

  def customer
    @customer ||= member.braintree_customer
  end

  def member
    Member.find_by(email: params[:user][:email])
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
    payment_options.merge(
      store_in_vault: ActiveRecord::Type::Boolean.new.type_cast_from_user(params[:store_in_vault]) || false
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

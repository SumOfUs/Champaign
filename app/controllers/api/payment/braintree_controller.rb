# frozen_string_literal: true

class Api::Payment::BraintreeController < PaymentController
  skip_before_action :verify_authenticity_token, raise: false

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
    @result = client::OneClick.new(params, cookies.signed[:payment_methods]).run
    render status: :unprocessable_entity unless @result.success?
  end

  private

  def payment_options
    {
      nonce: params[:payment_method_nonce],
      amount: params[:amount].to_f,
      user: params[:user].merge(mobile_value),
      currency: params[:currency],
      page_id: params[:page_id],
      store_in_vault: store_in_vault?
    }
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

# frozen_string_literal: true
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

class Api::Payment::BraintreeController < PaymentController
  skip_before_action :verify_authenticity_token

  def token
    render json: { token: ::Braintree::ClientToken.generate }
  end

  def webhook
    webhook_notification = Braintree::WebhookNotification.parse(params[:bt_signature], params[:bt_payload])
    client::WebhookHandler.handle(webhook_notification)
    render json: {success: true}
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

  def client
    PaymentProcessor::Clients::Braintree
  end

  def page
    @page ||= Page.find(params[:page_id])
  end

  def recurring?
    @recurring ||= ActiveRecord::Type::Boolean.new.type_cast_from_user( params[:recurring] )
  end
end

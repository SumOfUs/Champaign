class Api::BraintreeController < ApplicationController
  skip_before_action :verify_authenticity_token

  def token
    render json: { token: ::Braintree::ClientToken.generate }
  end

  def transaction
    builder = if recurring?
                client::Subscription.make_subscription(payment_options)
              else
                client::Transaction.make_transaction(payment_options)
              end

    if builder.result.success?
      write_member_cookie(builder.action.member_id) unless builder.action.blank?
      id = recurring? ? { subscription_id: builder.result.subscription.id } : { transaction_id: builder.result.transaction.id }

      render json: { success: true }.merge(id)
    else
      errors = client::ErrorProcessing.new(builder.result).process
      render json: { success: false, errors: errors }, status: 422
    end
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
      user: params[:user],
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

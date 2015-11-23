class Api::BraintreeController < ApplicationController
  skip_before_action :verify_authenticity_token


  def token
    render json: { token: ::Braintree::ClientToken.generate }
  end

  def transaction
    result = braintree::Transaction.make_transaction(transaction_options)
    if result.success?
      render json: { success: true, transaction_id: result.transaction.id }
    else
      render json: { success: false, errors: result.errors }
    end
  end

  def subscription
    result = braintree::Subscription.make_subscription(subscription_options)
    if result.success?
      render json: { success: true, subscription_id: result.subscription.id }
    else
      # Subscription-specific errors can be accessed with results.errors.for(:subscription),
      # but that would not include errors due to invalid parameters.
      # Subscription-specific errors are raised e.g. if there's an attempt to update a deleted subscription.
      render json: { success: false, errors: result.errors }
    end
  end

  private

  def transaction_options
    {
      nonce: params[:payment_method_nonce],
      user: params[:user],
      amount: params[:amount].to_f,
      store: Payment
    }
  end

  def subscription_options
    {
      price: params[:price].to_f,
      plan_id: '35wm',
      payment_method_token: default_payment_method_token
    }
  end

  def braintree
    PaymentProcessor::Clients::Braintree
  end

  def default_payment_method_token
    @token ||= ::Payment.customer(params[:email]).try(:card_vault_token)
  end
end

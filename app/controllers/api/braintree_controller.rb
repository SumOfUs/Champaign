class Api::BraintreeController < ApplicationController
  skip_before_action :verify_authenticity_token


  def token
    render json: { token: ::Braintree::ClientToken.generate }
  end

  def transaction
    if ActiveRecord::Type::Boolean.new.type_cast_from_user( params[:recurring] )
      # Rename key - 'price' sets subscription price, and that's specified in 'amount' for transactions.
      params[:price] = params.delete :amount
      manage_subscription(params)
    else
      manage_transaction(params)
    end
  end

  def subscription
    manage_subscription(params)
  end

  private

  def manage_transaction(params)
    result = braintree::Transaction.make_transaction(transaction_options)
    if result.success?
      render json: { success: true, transaction_id: result.transaction.id }
    else
      render json: { success: false, errors: result.errors }, status: 422
    end
  end

  def manage_subscription(params)
    find_or_create_user(params)
    result = braintree::Subscription.make_subscription(subscription_options)
    if result.success?
      render json: { success: true, subscription_id: result.subscription.id }
    else
      render json: { success: false, errors: result.errors }, status: 422
    end
  end

  def find_or_create_user(params)
    # If user isn't associated with a token locally, create and persist the customer first
    if default_payment_method_token.blank?
      result = braintree::Customer.create({
        email: params[:email],
        first_name: params[:first_name],
        last_name: params[:last_name],
        payment_method_nonce: params[:payment_method_nonce]
      })
      if not result.success?
        # render customer creation failure json - it's pointless to continue if there's no user (subscription will fail)
        render json: { success: false, errors: result.errors }, status: 422
      else
        # persist customer locally
        Payment::BraintreeCustomer.
            find_or_initialize_by(email: params[:email]).
            update_attributes!(card_vault_token: result.customer.payment_methods.first.token)
      end
    end
  end

  def transaction_options
    {
      nonce: params[:payment_method_nonce],
      amount: params[:amount].to_f,
      user: params[:user],
      store: Payment
    }
  end

  def subscription_options
    {
      price: params[:price].to_f,
      plan_id: ENV['BRAINTREE_SUBSCRIPTION_PLAN_ID'],
      payment_method_token: default_payment_method_token
    }
  end

  def braintree
    PaymentProcessor::Clients::Braintree
  end

  def default_payment_method_token
    @token ||= ::Payment.customer(params[:user][:email]).try(:card_vault_token)
  end
end

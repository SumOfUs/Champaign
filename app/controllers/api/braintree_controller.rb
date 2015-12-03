class Api::BraintreeController < ApplicationController
  skip_before_action :verify_authenticity_token

  def token
    render json: { token: ::Braintree::ClientToken.generate }
  end

  def transaction
    if ActiveRecord::Type::Boolean.new.type_cast_from_user( params[:recurring] )
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
      raise_unless_user_error(result)
      render json: { success: false, errors: result.errors }, status: 422
    end
  end

  def manage_subscription(params)
    find_or_create_user

    result = braintree::Subscription.make_subscription(subscription_options)

    if result.success?
      render json: { success: true, subscription_id: result.subscription.id }
    else
      errors = raise_unless_user_error(result)
      render json: { success: false, errors: errors }, status: 422
    end
  end

  def find_or_create_user
    user = params[:user]
    # If user isn't associated with a token locally, create and persist the customer first
    if default_payment_method_token.blank?
      result = braintree::Customer.create({
        email: user[:email],
        first_name: user[:first_name],
        last_name: user[:last_name],
        payment_method_nonce: params[:payment_method_nonce]
      })
      if not result.success?
        # render customer creation failure json - it's pointless to continue if there's no user (subscription will fail)
        render json: { success: false, errors: result.errors }, status: 422
      else
        # persist customer locally

        customer = Payment::BraintreeCustomer.find_or_initialize_by(email: user[:email])
        customer.update(
          card_vault_token: result.customer.payment_methods.first.token,
          customer_id: result.customer.id,
          first_name: user[:firstname] || user[:name],
          last_name: user[:last_name]
        )
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
      price: params[:amount].to_f,
      plan_id: Settings.braintree_subscription_plan_id,
      payment_method_token: default_payment_method_token
    }
  end

  def braintree
    PaymentProcessor::Clients::Braintree
  end

  def default_payment_method_token
    ::Payment.customer(params[:user][:email]).try(:card_vault_token)
  end

  def raise_unless_user_error(result)
    braintree::ErrorProcessing.new(result).process
  end
end


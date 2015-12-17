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
      action = ManageAction.create( params[:user].merge(page_id: params[:page_id]) )
      Payment.write_successful_transaction(action: action, transaction_response: result)
      render json: { success: true, transaction_id: result.transaction.id }
    else
      errors = raise_unless_user_error(result)
      render json: { success: false, errors: errors }, status: 422
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
        name: user[:name] || user[:full_name],
        payment_method_nonce: params[:payment_method_nonce]
      })

      if not result.success?
        # render customer creation failure json - it's pointless to continue if there's no user (subscription will fail)
        render json: { success: false, errors: result.errors }, status: 422
      else
        # persist customer locally
        action = ManageAction.create( params[:user].merge(page_id: params[:page_id]) )
        customer = action.member.customer || Payment::BraintreeCustomer.find_or_initialize_by(member_id: action.member_id)

        customer.update(
          card_vault_token: result.customer.payment_methods.first.token,
          customer_id: result.customer.id,
          name: user[:name] || user[:full_name],
          card_last_4: result.customer.payment_methods.first.last_4
        )
        result
      end
    end
  end

  def transaction_options
    {
      nonce: params[:payment_method_nonce],
      amount: params[:amount].to_f,
      user: params[:user],
      currency: params[:currency],
      customer: Payment.customer(params[:user][:email])
    }
  end

  def subscription_options
    {
      price: params[:amount].to_f,
      payment_method_token: default_payment_method_token,
      currency: params[:currency],
      store: Payment
    }
  end

  def braintree
    PaymentProcessor::Clients::Braintree
  end

  def default_payment_method_token
   local_customer.try(:card_vault_token)
  end

  def local_customer
    @local_customer ||= ::Payment.customer(params[:user][:email])
  end

  def raise_unless_user_error(result)
    braintree::ErrorProcessing.new(result).process
  end

  def page
    @page ||= Page.find(params[:page_id])
  end
end


class Api::BraintreeController < ApplicationController
  skip_before_action :verify_authenticity_token

  def token
    render json: { token: ::Braintree::ClientToken.generate }
  end

  def transaction
    builder = if recurring?
                braintree::Subscription.make_subscription(transaction_options)
              else
                braintree::Transaction.make_transaction(transaction_options)
              end
    if builder.result.success?
      write_member_cookie(builder.action.member_id) unless action.blank?
      id = recurring? ? { subscription_id: result.subscription.id } : { transaction_id: result.transaction.id }
      render json: { success: true }.merge(id)
    else
      errors = raise_unless_user_error(builder.result)
      render json: { success: false, errors: errors }, status: 422
    end
  end

  def webhook
    webhook_notification = Braintree::WebhookNotification.parse(params[:bt_signature], params[:bt_payload])

    if webhook_notification.kind == Braintree::WebhookNotification::Kind::SubscriptionChargedSuccessfully
      card_num = webhook_notification.subscription.transactions.last.credit_card_details.last_4
      query_params = {
          is_subscription: true,
          email: webhook_notification.subscription.transactions.last.customer_details.email,
          card_num: card_num.nil? ? ManageBraintreeDonation::PAYPAL_IDENTIFIER : card_num,
          amount: webhook_notification.subscription.transactions.last.amount.to_s
      }
      action = Action.where('form_data @> ?', query_params.to_json).last
      member = Member.find(action.member_id)

      params = {
        email:   member.email,
        country: member.country,
        page_id: action.page_id
      }

      ManageBraintreeDonation.create(params: params, braintree_result: webhook_notification, is_subscription: true)
    end
    render json: {success: true}
  end

  private

  # Deprecated, delete this
  def manage_subscription(params)
    result = braintree::Subscription.make_subscription(transaction_options)
    if result.success?
      action = ManageBraintreeDonation.create(params: params[:user].merge(page_id: params[:page_id]), braintree_result: result, is_subscription: true)
      write_member_cookie(action.member_id) unless action.blank?
      render json: { success: true, subscription_id: result.subscription.id }
    else
      errors = raise_unless_user_error(result)
      render json: { success: false, errors: errors }, status: 422
    end
  end

  # Deprecated, delete this
  def manage_transaction(params)
    result = braintree::Transaction.make_transaction(transaction_options)

    if result.success?
      action = ManageBraintreeDonation.create(params: params[:user].merge(page_id: params[:page_id]), braintree_result: result)
      Payment.write_successful_transaction(action: action, transaction_response: result)
      write_member_cookie(action.member_id) unless action.blank?
      render json: { success: true, transaction_id: result.transaction.id }
    else
      errors = raise_unless_user_error(result)
      render json: { success: false, errors: errors }, status: 422
    end
  end

  def transaction_options
    {
      nonce: params[:payment_method_nonce],
      amount: params[:amount].to_f,
      user: params[:user],
      currency: params[:currency],
      page_id: params[:page_id],
      customer: Payment.customer(params[:user][:email])
    }
  end

  def braintree
    PaymentProcessor::Clients::Braintree
  end

  # Deprecated, delete this
  def default_payment_method_token
   local_customer.try(:card_vault_token)
  end

  # Deprecated, delete this
  def local_customer
    @local_customer ||= ::Payment.customer(params[:user][:email])
  end

  def raise_unless_user_error(result)
    braintree::ErrorProcessing.new(result).process
  end

  def page
    @page ||= Page.find(params[:page_id])
  end

  def recurring?
    @recurring ||= ActiveRecord::Type::Boolean.new.type_cast_from_user( params[:recurring] )
  end
end

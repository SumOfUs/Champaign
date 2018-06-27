# frozen_string_literal: true

class Api::Payment::BraintreeController < PaymentController
  skip_before_action :verify_authenticity_token, raise: false

  def token
    render json: { token: ::Braintree::ClientToken.generate }
  end

  def webhook
    if client::WebhookHandler.handle(unsafe_params[:bt_signature], unsafe_params[:bt_payload])
      head :ok
    else
      head :not_found
    end
  end

  def one_click
    @result = client::OneClick.new(unsafe_params, cookies.signed[:payment_methods]).run
    render status: :unprocessable_entity unless @result.success?
  end

  private

  def payment_options
    {
      nonce: unsafe_params[:payment_method_nonce],
      amount: unsafe_params[:amount].to_f,
      user: unsafe_params[:user].merge(mobile_value),
      currency: unsafe_params[:currency],
      page_id: unsafe_params[:page_id],
      store_in_vault: store_in_vault?
    }.tap do |options|
      if unsafe_params[:extra_action_fields].present?
        options[:extra_params] = unsafe_params[:extra_action_fields]
      end
    end
  end

  def client
    PaymentProcessor::Braintree
  end

  def page
    @page ||= Page.find(unsafe_params[:page_id])
  end

  def recurring?
    @recurring ||= ActiveRecord::Type::Boolean.new.cast(unsafe_params[:recurring])
  end
end

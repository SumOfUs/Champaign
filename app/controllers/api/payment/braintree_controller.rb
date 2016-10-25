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

  def link_payment
    pmid = current_member.customer.payment_methods.first.id

    opts = ActionController::Parameters.new(
      payment: {
        payment_method_id: pmid,
        currency: params[:currency],
        amount: params[:amount]
      },
      user: {
        email: current_member.email
      },
      page_id: params[:page_id]
    )

    client::OneClick.new(opts).run

    render text: page.title
  end

  def one_click
    client::OneClick.new(params).run
    render json: { success: true }
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

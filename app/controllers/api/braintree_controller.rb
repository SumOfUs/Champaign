class Api::BraintreeController < ApplicationController
  def token
    render json: {token: ::Braintree::ClientToken.generate}
  end

  def transaction
    sale = braintree.make_transaction(options)

    if sale.success?
      render json: { success: true, transaction_id: sale.transaction_id }
    else
      render json: { success: false, errors: [] }
    end
  end

  private

  def options
    {
      payment_method_nonce: params[:payment_method_nonce],
      amount: params[:amount],
      user: params[:user]
    }
  end

  def braintree
    PaymentProcessor::Clients::Braintree::Transaction
  end
end

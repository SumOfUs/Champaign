class Api::BraintreeController < ApplicationController

  def token
    render json: {token: ::Braintree::ClientToken.generate}
  end

  def transaction
    sale = braintree.make_transaction(options)

    if sale.success?
      render json: { success: true, transaction_id: sale.transaction.id }
    else
      render json: { success: false, errors: sale.errors }
    end
  end

  private

  def options
    {
      nonce: params[:payment_method_nonce],
      user: params[:user],
      amount: params[:amount].to_i
    }
  end

  def braintree
    PaymentProcessor::Clients::Braintree::Transaction
  end

end

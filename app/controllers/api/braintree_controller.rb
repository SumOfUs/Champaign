class Api::BraintreeController < ApplicationController
  # TODO: replace with something smarter / safer
  skip_before_filter :verify_authenticity_token

  def token
    render json: {token: ::Braintree::ClientToken.generate}
  end

  def transaction
    # we could use permitted params instead of params.except(:action, :controller)
    # render json: PaymentProcessor::Clients::Braintree::Transaction.make_transaction(params.except(:action, :controller))
    sale = braintree.make_transaction(options)

    if sale.success?
      render json: { success: true, transaction_id: sale.transaction.id }
    else
      render json: { success: false, errors: [] }
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

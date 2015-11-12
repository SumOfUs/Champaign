class Api::BraintreeController < ApplicationController
  def token
    render json: {token: ::Braintree::ClientToken.generate}
  end

  def transaction
    # we could use permitted params instead of params.except(:action, :controller)
    render json: PaymentProcessor::Clients::Braintree::Transaction.make_transaction(params.except(:action, :controller))
  end
end

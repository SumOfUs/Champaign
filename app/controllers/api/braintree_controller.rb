class Api::BraintreeController < ApplicationController
  def token
    render json: {token: Braintree::ClientToken.generate}
  end

  def transaction

  end
end

class Api::GoCardlessController < ApplicationController
  skip_before_action :verify_authenticity_token

  def start_flow
    # Generate a success URL. This is where GC will send the customer after they've paid.
    string_params = request.url.split('?').last
    success_url = "#{request.base_url}/api/go_cardless/payment_complete?#{string_params}"

    redirect_flow = client.redirect_flows.create(params: {
      session_token: session.id,
      success_redirect_url: success_url
    })
    redirect_to redirect_flow.redirect_url
  end

  def payment_complete
    # this is a standin until tuuli's namespacing PR is merged and we can use 1 payment endpoint
  end

  private

  def client
    GoCardlessPro::Client.new(
      access_token: Settings.gocardless.token,
      environment: Settings.gocardless.environment.to_sym
    )
  end

end

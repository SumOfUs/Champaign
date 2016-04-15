class GoCardlessDirector
  def initialize(session_id, success_url)
    @session_id = session_id
    @success_url = success_url

  end

  def redirect_url
    redirect_flow_instance.redirect_url
  end

  def redirect_flow_instance
    @redirect_flow_instance ||= client.redirect_flows.create(params: {
      session_token:        @session_id,
      success_redirect_url: @success_url
    })
  end

  def client
    @client ||= GoCardlessPro::Client.new(
      access_token: Settings.gocardless.token,
      environment:  Settings.gocardless.environment.to_sym
    )
  end
end

class Api::GoCardlessController < ApplicationController
  skip_before_action :verify_authenticity_token

  def start_flow
    flow = GoCardlessDirector.new(session.id, success_url)
    redirect_to flow.redirect_url
  end

  def payment_complete
    # If one-off payment
    builder.make_transaction(params, session.id)
    render json: {success: builder.success?, params: params}
  end

  def webhook
    head :ok
  end

  private

  def builder
    PaymentProcessor::GoCardless::Transaction
  end

  def client
    GoCardlessPro::Client.new(
      access_token: Settings.gocardless.token,
      environment: Settings.gocardless.environment.to_sym
    )
  end

  def success_url
    local_params = URI.parse(request.url).query + "&page_id=#{params[:page_id]}"
    "#{request.base_url}/api/go_cardless/payment_complete?#{local_params}"
  end
end

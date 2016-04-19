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
    builder = if recurring?
                client::Subscription.make_subscription(params, session.id)
              else
                client::Transaction.make_transaction(params, session.id)
              end
    render json: {success: builder.success?, params: params}
  end

  def webhook
    head :ok
  end

  private

  def success_url
    local_params =  Rack::Utils.parse_query(
      URI.parse(request.url).query
    ).merge( params.slice(:page_id) ).to_query

    "#{request.base_url}/api/go_cardless/payment_complete?#{local_params}"
  end

  def client
    PaymentProcessor::GoCardless
  end

  def recurring?
    @recurring ||= ActiveRecord::Type::Boolean.new.type_cast_from_user( params[:recurring] )
  end

end

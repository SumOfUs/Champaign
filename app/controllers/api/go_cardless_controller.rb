class Api::GoCardlessController < PaymentController
  skip_before_action :verify_authenticity_token

  def start_flow
    flow = GoCardlessDirector.new(session.id, success_url)
    redirect_to flow.redirect_url
  end

  def webhook
    signature = request.headers['HTTP_WEBHOOK_SIGNATURE']

    validator = PaymentProcessor::GoCardless::WebhookSignature.new(
      secret: 'monkey',
      signature: signature,
      body: { events: params[:events] }.to_json
    )

    if validator.valid?
      PaymentProcessor::GoCardless::WebhookHandler::ProcessEvents.process(params[:events])
      head :ok
    else
      head status: 427
    end
  end

  private

  def success_url
    local_params =  Rack::Utils.parse_query(
      URI.parse(request.url).query
    ).merge( params.slice(:page_id) ).to_query

    "#{request.base_url}/api/go_cardless/transaction?#{local_params}"
  end

  def client
    PaymentProcessor::GoCardless
  end

  def payment_options
    {
      amount: params[:amount],
      currency: params[:currency],
      user: params[:user],
      page_id: params[:page_id],
      redirect_flow_id: params[:redirect_flow_id],
      session_token: session.id
    }
  end
end



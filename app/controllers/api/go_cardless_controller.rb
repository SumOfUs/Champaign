# frozen_string_literal: true

class Api::GoCardlessController < PaymentController
  skip_before_action :verify_authenticity_token, raise: false

  def start_flow
    session[:go_cardless_session_id] = SecureRandom.uuid
    @flow = GoCardlessDirector.new(session[:go_cardless_session_id], success_url, unsafe_params)

    if @flow.success?
      redirect_to @flow.redirect_url
    else
      @errors = client::ErrorProcessing.new(@flow.error).process
      render 'payment/donation_errors', layout: 'member_facing'
    end
  end

  def webhook
    signature = request.headers['HTTP_WEBHOOK_SIGNATURE']

    validator = Api::HMACSignatureValidator.new(
      secret: Settings.gocardless.secret,
      signature: signature,
      data: { events: unsafe_params[:events] }.to_json
    )

    if validator.valid?
      PaymentProcessor::GoCardless::WebhookHandler::ProcessEvents.process(unsafe_params[:events])
      head :ok
    else
      head 427
    end
  end

  private

  def success_url
    local_params = Rack::Utils.parse_query(
      URI.parse(request.url).query
    ).merge(unsafe_params.slice(:page_id)).to_query

    "#{request.base_url}/api/go_cardless/pages/#{page.id}/transaction?#{local_params}"
  end

  def client
    PaymentProcessor::GoCardless
  end

  def payment_options
    {
      amount: unsafe_params[:amount],
      currency: unsafe_params[:currency],
      user: unsafe_params[:user].merge(mobile_value),
      page_id: unsafe_params[:page_id],
      redirect_flow_id: unsafe_params[:redirect_flow_id],
      session_token: session[:go_cardless_session_id]
    }.tap do |options|
      options[:extra_params] = unsafe_params[:extra_action_fields] if unsafe_params[:extra_action_fields].present?
      options[:extra_params] ||= {}
      options[:extra_params][:source] = params[:source] if params[:source].present?
    end
  end

  def transaction_options
    payment_options
  end
end

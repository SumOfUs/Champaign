class GoCardlessDirector
  attr_reader :error

  def initialize(session_id, success_url, params)
    @session_id = session_id
    @success_url = success_url
    @params = params
    redirect_flow_instance # so we know if it's a success
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

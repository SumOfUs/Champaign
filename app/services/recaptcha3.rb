class Recaptcha3
  include HTTParty
  base_uri 'https://www.google.com/recaptcha'

  attr_reader :resp, :action, :errors

  def initialize(token:, action:)
    @action = action
    @errors = []

    @options = { query: {
      secret: Settings.recaptcha3.secret_key,
      response: token
    } }
  end

  def human?
    verify

    errors.empty? && @response.dig(:success) &&
      (@response.dig(:score).to_f > Settings.recaptcha3.min_score.to_f) &&
      @response.dig(:action) == @action
  end

  private

  def verify
    begin
      @resp = self.class.get('/api/siteverify', @options)
      @response = @resp.try(:parsed_response).to_h.with_indifferent_access
    rescue HTTParty::Error => e
      Raven.capture_exception(e)
      @errors << 'Error occurred while processing payment. Please try again'
    end
    @resp
  end
end

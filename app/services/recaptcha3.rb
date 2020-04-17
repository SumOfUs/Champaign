class Recaptcha3
  include HTTParty
  base_uri 'https://www.google.com/recaptcha'

  attr_reader :token, :resp, :action

  def initialize(token:, action:)
    @token  = token
    @action = action
    @errors = []
  end

  def errors
    @errors.flatten.compact.uniq
  end

  def human?
    return false unless valid?

    verify
    errors.empty? && success? && valid_action? && valid_score?
  end

  def valid?
    @errors << "Token can't be blank"  unless token.present?
    @errors << "Action can't be blank" unless action.present?

    @errors << "Secret key can't be blank" unless http_options.dig(:query, :secret).present?
    @errors.empty?
  end

  def score
    @response.dig(:score).to_f
  end

  private

  def verify
    begin
      @resp = self.class.get('/api/siteverify', http_options)
      @response = @resp.try(:parsed_response).to_h.with_indifferent_access
      @errors << error_codes.join(', ') if error_codes.present?
    rescue HTTParty::Error => e
      Raven.capture_exception(e)
      @errors << 'Error occurred while processing payment. Please try again'
    end
    @resp
  end

  def http_options
    { query: { secret: Settings.recaptcha3.secret_key,
               response: token } }
  end

  def valid_action?
    @response.dig(:action) == @action
  end

  def success?
    @response.dig(:success)
  end

  def valid_score?
    (@response.dig(:score).to_f > Settings.recaptcha3.min_score.to_f)
  end

  def error_codes
    @response.dig('error-codes').to_a
  end
end

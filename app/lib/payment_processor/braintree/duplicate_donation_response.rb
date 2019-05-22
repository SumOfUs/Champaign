module PaymentProcessor::Braintree
  class DuplicateDonationResponse
    attr_accessor :errors, :message, :params
    attr_reader   :immediate_redonation

    def initialize(errors: [], message: '', params: {})
      @errors   = errors
      @message  = message
      @params   = params
      @immediate_redonation = true
    end

    def success?
      @errors.empty?
    end
  end
end

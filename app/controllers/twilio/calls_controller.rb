module Twilio
  class CallsController < ApplicationController
    skip_before_action :verify_authenticity_token, only: [:twiml]

    def twiml
      @call = Call.find(params[:id])
      render xml: TwimlGenerator.run(@call)
    end
  end
end

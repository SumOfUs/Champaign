# frozen_string_literal: true
module Twilio
  class CallsController < ApplicationController
    before_filter :find_call
    skip_before_action :verify_authenticity_token

    def twiml
      render xml: TwimlGenerator.run(@call)
    end

    def log
      @call.update(log: params)
      head :ok
    end

    private

    def find_call
      @call = Call.find(params[:id])
    end
  end
end

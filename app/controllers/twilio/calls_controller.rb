# frozen_string_literal: true
module Twilio
  class CallsController < ApplicationController
    skip_before_action :verify_authenticity_token

    def twiml
      @call = Call.find(params[:id])
      render xml: TwimlGenerator.run(@call)
    end

    def log
      @call = Call.find(params[:id])
      @call.update!(target_call_info: params)
      render xml: Twilio::TwiML::Response.new.text
    end

    def create_event
      @call = Call.find(params[:id])
      @call.member_call_events << params
      @call.save!
      head :ok
    end
  end
end

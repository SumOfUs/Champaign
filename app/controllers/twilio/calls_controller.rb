# frozen_string_literal: true
module Twilio
  class CallsController < ApplicationController
    skip_before_action :verify_authenticity_token

    def start
      @call = Call.find(params[:id])
      @call.started! if @call.unstarted?
      render xml: TwimlGenerator::StartCall.run(@call)
    end

    def connect
      @call = Call.find(params[:id])
      @call.connected! if @call.started?
      render xml: TwimlGenerator::ConnectCall.run(@call)
    end

    def create_target_call_status
      @call = Call.find(params[:id])
      @call.update!(target_call_info: params)
      render xml: Twilio::TwiML::Response.new.text
    end

    def create_member_call_event
      @call = Call.find(params[:id])
      @call.member_call_events << params
      @call.save!
      head :ok
    end
  end
end

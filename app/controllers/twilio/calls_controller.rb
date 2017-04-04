# frozen_string_literal: true
module Twilio
  class CallsController < ApplicationController
    skip_before_action :verify_authenticity_token

    def start
      @call = Call.find(params[:id])
      @call.started! if @call.unstarted?
      render xml: CallTool::TwimlGenerator::Start.run(@call)
    end

    def menu
      @call = Call.find(params[:id])
      render xml: CallTool::TwimlGenerator::Menu.run(@call, menu_params)
    end

    def connect
      @call = Call.find(params[:id])
      @call.connected! if @call.started?
      render xml: CallTool::TwimlGenerator::Connect.run(@call)
    end

    def create_target_call_status
      @call = Call.find(params[:id])
      @call.update!(target_call_info: params)
      render xml: CallTool::TwimlGenerator::Empty.run
    end

    def create_member_call_event
      @call = Call.find(params[:id])
      @call.member_call_events << params
      @call.save!
      head :ok
    end

    private

    def menu_params
      params.slice('Digits')
    end
  end
end

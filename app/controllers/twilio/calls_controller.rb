# frozen_string_literal: true

module Twilio
  class CallsController < ApplicationController
    skip_before_action :verify_authenticity_token, raise: false

    def start
      @call = Call.find(params[:id])
      CallTool::CallStatusUpdater.start!(@call)
      render xml: CallTool::TwimlGenerator::Start.run(@call)
    end

    def menu
      @call = Call.find(params[:id])
      render xml: CallTool::TwimlGenerator::Menu.run(@call, menu_params)
    end

    def connect
      @call = Call.find(params[:id])
      CallTool::CallStatusUpdater.connect!(@call)
      render xml: CallTool::TwimlGenerator::Connect.run(@call)
    end

    def create_target_call_status
      @call = Call.find(params[:id])
      CallTool::CallStatusUpdater.update!(@call, target_call_info: params)
      render xml: CallTool::TwimlGenerator::Empty.run
    end

    def create_member_call_event
      @call = Call.find(params[:id])
      CallTool::CallStatusUpdater.new_member_call_event!(@call, params)
      head :ok
    end

    private

    def menu_params
      params.slice('Digits')
    end
  end
end

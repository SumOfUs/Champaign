# frozen_string_literal: true

module Twilio
  class CallsController < ApplicationController
    skip_before_action :verify_authenticity_token, raise: false

    def start
      @call = Call.find(params[:id])
      CallTool::CallStatusUpdater.start!(@call)
      xml = CallTool::TwimlGenerator::Start.run(@call)
      render xml: xml
    end

    def menu
      @call = Call.find(params[:id])
      xml = CallTool::TwimlGenerator::Menu.run(@call, menu_params)
      render xml: xml
    end

    def connect
      @call = Call.find(params[:id])
      CallTool::CallStatusUpdater.connect!(@call)
      xml = CallTool::TwimlGenerator::Connect.run(@call)
      render xml: xml
    end

    def create_target_call_status
      @call = Call.find(params[:id])
      CallTool::CallStatusUpdater.update!(@call, target_call_info: params)
      xml = CallTool::TwimlGenerator::Empty.run
      render xml: xml
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

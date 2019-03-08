# frozen_string_literal: true

module Twilio
  class CallsController < ApplicationController
    skip_before_action :verify_authenticity_token, raise: false

    def start
      @call = Call.find(params[:id])
      CallTool::CallStatusUpdater.start!(@call)
      xml = CallTool::TwimlGenerator::Start.run(@call)
      pp 'START XML: ', xml
      render xml: xml
    end

    def menu
      @call = Call.find(params[:id])
      xml = CallTool::TwimlGenerator::Menu.run(@call, menu_params)
      pp 'FIND XML: ', xml
      render xml: xml
    end

    def connect
      @call = Call.find(params[:id])
      CallTool::CallStatusUpdater.connect!(@call)
      xml = CallTool::TwimlGenerator::Connect.run(@call)
      pp 'CONNECT XML: ', xml
      render xml: xml
    end

    def create_target_call_status
      @call = Call.find(params[:id])
      CallTool::CallStatusUpdater.update!(@call, target_call_info: params)
      xml = CallTool::TwimlGenerator::Empty.run
      pp 'CREATE TARGET CALL STATUS XML: ', xml
      render xml: xml
    end

    def create_member_call_event
      @call = Call.find(params[:id])
      res = CallTool::CallStatusUpdater.new_member_call_event!(@call, params)
      pp 'CREATE MEMBER CALL EVENT RES: ', res
      # TODO: - does this always respond ok?
      head :ok
    end

    private

    def menu_params
      params.slice('Digits')
    end
  end
end

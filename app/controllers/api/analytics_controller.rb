# frozen_string_literal: true
class Api::AnalyticsController < ApplicationController
  layout false

  def show
    respond_to do |format|
      format.json do
        @page = Analytics::Page.new( params[:page_id] )
      end
    end
  end
end


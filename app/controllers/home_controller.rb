# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    if user_signed_in?
      redirect_to pages_path
    else
      redirect_to Settings.home_page_url
    end
  end

  def health_check
    render plain: health_check_haiku, status: 200
  end

  def robots
    robots = File.read(Rails.root + "config/robots.#{Settings.robots}.txt")
    render plain: robots
  end

  private

  def health_check_haiku
    "Health check is passing,\n"\
    "don't terminate the instance.\n"\
    'Response: 200.'
  end
end

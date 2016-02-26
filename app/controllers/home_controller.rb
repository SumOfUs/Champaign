class HomeController < ApplicationController

  def index
    # left blank on purpose
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
    "Response: 200."
  end

end

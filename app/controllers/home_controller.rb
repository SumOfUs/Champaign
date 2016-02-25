class HomeController < ApplicationController

  def index
    # left blank on purpose
  end

  # Devise hooks into this method to determine where to redirect after a user signs in.
  # Because we redirect the root path to sumofus.org (which is not handled by this app),
  # we need to send the user to a page controlled by Champaign. In this case, the Page Index
  # works as a standard start point for campaigners.
  def after_sign_in_path_for(user)
    pages_url
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

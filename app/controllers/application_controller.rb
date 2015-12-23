class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Devise hooks into this method to determine where to redirect after a user signs in.
  # Because we redirect the root path to sumofus.org (which is not handled by this app),
  # we need to send the user to a page controlled by Champaign. In this case, the Page Index
  # works as a standard start point for campaigners.
  def after_sign_in_path_for(user)
    pages_url
  end

end

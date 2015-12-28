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

  private

  def localize_from_page_id
    page = Page.find_by(id: params[:page_id])
    if page.present? && page.language.present? && page.language.code.present?
      set_locale(page.language.code)
    end
  end

  def set_locale(code)
    begin
      I18n.locale = code
    rescue I18n::InvalidLocale
      # by setting the +i18n.enforce_available_locales+ flag to true but
      # catching the resulting error, it allows us to only set the locale
      # if it's one explicitly registered under +i18n.available_locales+
    end
  end
end

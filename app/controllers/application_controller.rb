class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

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

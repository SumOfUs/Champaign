class ApplicationController < ActionController::Base
  before_filter :set_locale

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

  def localize_from_page_id(id)
    @page = Page.find_by(id: id)
    if @page.present? && @page.language.present? && @page.language.code.present?
      I18n.locale = @page.language.code
    end
  end

  def set_locale
    # I18n doesn't work on a per-request basis on a multi-threaded server, so what I'm doing is forcing it to
    # check what localization should be use on a per-request basis. This gets called on all requests, and the
    # case goes through different controllers, checks whether it could be a controller where internalization
    # would be required (for api/actions and pages), and then sets the locality if appropriate.
    #
    # Note that this has broken form validation right now - I'm not exactly sure why that would be, but I get
    # a 500 for the jquery request.
    begin
      controller = params[:controller]
      case controller
        when 'api/actions'
          localize_from_page_id(params[:page_id])
        when 'pages'
          if params[:id].blank?
            I18n.locale = I18n.default_locale
          else
            localize_from_page_id(params[:id])
          end
        else
          I18n.locale = I18n.default_locale
      end
    rescue I18n::InvalidLocale
      # by setting the +i18n.enforce_available_locales+ flag to true but
      # catching the resulting error, it allows us to only set the locale
      # if it's one explicitly registered under +i18n.available_locales+
    end
  end
end

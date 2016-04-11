class ApplicationController < ActionController::Base
  before_filter :set_default_locale

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

  def set_locale(code)
    begin
      I18n.locale = code
    rescue I18n::InvalidLocale
      # by setting the +i18n.enforce_available_locales+ flag to true but
      # catching the resulting error, it allows us to only set the locale
      # if it's one explicitly registered under +i18n.available_locales+
    end
  end

  def localize_from_page_id
    page = Page.find_by(id: params[:page_id])
    localize_by_page_language(page)
  end

  def localize_by_page_language(page)
    if page.present? && page.language.present? && page.language.code.present?
      set_locale(page.language.code)
    end
  end

  def set_default_locale
    I18n.locale = I18n.default_locale
  end

  def write_member_cookie(member_id)
    cookies.signed[:member_id] = {
      value: member_id,
      expires: 2.years.from_now
    }
  end

  def mobile_value
    device = MobileDetect.new({
        HTTP_USER_AGENT: request.user_agent,
        HTTP_ACCEPT: request.accept,
        HTTP_ACCEPT_LANGUAGE: request.accept_language,
        HTTP_ACCEPT_ENCODING: request.accept_encoding
    }, request.user_agent)

    device_hash = {
        mobile: nil
    }
    if device.mobile?
      device_hash[:mobile] = 'mobile'
    elsif device.tablet?
      device_hash[:mobile] = 'tablet'
    else
      device_hash[:mobile] = 'desktop'
    end

    device_hash
  end

  def referer_url
    {referer: request.referer}
  end
end

# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include AuthToken

  before_action :set_default_locale
  before_action :set_raven_context

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Devise hooks into this method to determine where to redirect after a user signs in.
  # Because we redirect the root path to sumofus.org (which is not handled by this app),
  # we need to send the user to a page controlled by Champaign. In this case, the Page Index
  # works as a standard start point for campaigners.
  def after_sign_in_path_for(_user)
    pages_url
  end

  def mobile_value
    MobileDetector.detect(browser)
  end

  private

  def set_default_locale
    set_locale(I18n.default_locale)
  end

  def set_locale(code)
    I18n.locale = code
  rescue I18n::InvalidLocale
    # by setting the +i18n.enforce_available_locales+ flag to true but
    # catching the resulting error, it allows us to only set the locale
    # if it's one explicitly registered under +i18n.available_locales+
  end

  def localize_from_page_id
    page = Page.find_by(id: unsafe_params[:page_id])
    set_locale(page.language_code) if page.present?
  end

  def write_member_cookie(member_id)
    cookies.signed[:member_id] = {
      value: member_id,
      expires: 2.years.from_now
    }
  end

  def referer_url
    { action_referer: request.referer }
  end

  def renderer
    @renderer ||= LiquidRenderer.new(@page, location: request.location,
                                            member: recognized_member,
                                            url_params: unsafe_params,
                                            payment_methods: payment_methods)
  end

  def payment_methods
    if current_member
      PaymentMethodFetcher.new(current_member).fetch
    else
      payment_method_ids = (cookies.signed[:payment_methods] || '').split(',')
      PaymentMethodFetcher.new(recognized_member, filter: payment_method_ids).fetch
    end
  end

  def current_member
    return nil if cookies.signed[:authentication_id].nil?

    payload = decode_jwt(cookies.signed[:authentication_id])
    @current_member ||= Member.find_by(id: payload['id'])
  end

  def recognized_member
    @recognized_member ||= current_member ||
                           Member.find_from_request(akid: unsafe_params[:akid], id: cookies.signed[:member_id])
  end

  def authenticate_super_admin!
    return true if authenticate_user! && Settings.admins =~ Regexp.new(current_user.email)
    raise SecurityError, "#{current_user.email} is not an administrator."
  end

  def unsafe_params
    params.to_unsafe_hash
  end

  def set_raven_context
    Raven.user_context(id: recognized_member&.id)
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
  end
end

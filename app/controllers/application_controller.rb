# frozen_string_literal: true

class PaymentMethodFetcher
  def initialize(member, filter: [])
    @member = member
    @filter = filter
    puts 'OMAR OMAR'
    puts @filter
  end

  def fetch
    return [] unless @member && @member.customer

    tokens = if @filter.any?
               @member.customer.payment_methods.where(token: @filter)
             else
               @member.customer.payment_methods.stored
             end

    tokens.map do |m|
      {
        id: m.id,
        last_4: m.last_4,
        instrument_type: m.instrument_type,
        card_type: m.card_type,
        email: m.email,
        token: m.token
      }
    end
  end
end

class ApplicationController < ActionController::Base
  before_filter :set_default_locale

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

  def set_locale(code)
    I18n.locale = code
  rescue I18n::InvalidLocale
    # by setting the +i18n.enforce_available_locales+ flag to true but
    # catching the resulting error, it allows us to only set the locale
    # if it's one explicitly registered under +i18n.available_locales+
  end

  def localize_from_page_id
    page = Page.find_by(id: params[:page_id])
    localize_by_page_language(page)
  end

  def localize_by_page_language(page)
    return unless page.present? && page.language.present? && page.language.code.present?
    set_locale(page.language.code)
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

  def referer_url
    { action_referer: request.referer }
  end

  def render_liquid(liquid_layout, view)
    return redirect_to(Settings.home_page_url) unless @page.published? || user_signed_in?
    localize_by_page_language(@page)

    @rendered = renderer(liquid_layout).render
    @data = renderer(liquid_layout).personalization_data
    render "pages/#{view}", layout: 'member_facing'
  end

  def payment_methods
    # if signed_in?
    # PaymentMethodFetcher.new(recognized_member).fetch
    # else
    PaymentMethodFetcher.new(recognized_member, filter: cookies.signed[:payment_methods].split(',')).fetch
    # end
  end

  def renderer(layout)
    @renderer ||= LiquidRenderer.new(@page, location: request.location,
                                            member: recognized_member,
                                            layout: layout,
                                            url_params: params,
                                            payment_methods: payment_methods)
  end

  def recognized_member
    # FIXME
    @recognized_member ||= Member.find_from_request(akid: params[:akid], id: cookies.signed[:member_id])
  end
end

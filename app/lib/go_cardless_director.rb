# frozen_string_literal: true

class GoCardlessDirector
  attr_reader :error

  def initialize(session_id, success_url, params)
    @session_id = session_id
    @success_url = success_url
    @params = params
    redirect_flow_instance # so we know if it's a success
  end

  def redirect_url
    redirect_flow_instance.redirect_url
  end

  def redirect_flow_instance
    @redirect_flow_instance ||= client.redirect_flows.create(params: {
      session_token:        @session_id,
      description:          description,
      success_redirect_url: @success_url
    })
  rescue GoCardlessPro::Error => e
    @error = e
  end

  def success?
    @error.blank?
  end

  def description
    if recurring?
      I18n.t('fundraiser.debit.recurring', amount: amount_string, locale: locale)
    else
      I18n.t('fundraiser.debit.one_time', amount: amount_string, locale: locale)
    end
  end

  def client
    @client ||= GoCardlessPro::Client.new(
      access_token: Settings.gocardless.token,
      environment:  Settings.gocardless.environment.to_sym
    )
  end

  private

  def locale
    Page.includes(:language).find(@params[:page_id]).language.code
  end

  def recurring?
    ActiveRecord::Type::Boolean.new.cast(@params[:recurring])
  end

  def amount_string
    Money.new(@params[:amount].to_f * 100, @params[:currency]).format
  end
end

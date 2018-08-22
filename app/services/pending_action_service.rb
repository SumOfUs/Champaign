# frozen_string_literal: true

class PendingActionService
  attr_reader :email, :payload, :action
  delegate :data, to: :action

  class << self
    def create(payload)
      new(payload).create
    end
  end

  def initialize(payload)
    @payload = payload
  end

  def create
    @action = PendingAction.create(
      email: payload[:email],
      data: payload,
      token: token,
      page: page
    )

    self
  end

  def send_email(version: 1)
    EmailDelivery.send_email(
      action,
      html: html(version),
      text: text(version),
      subject: I18n.t("double_opt_in_#{version}.email.subject", locale: page.language_code)
    )
  end

  private

  def token
    @token ||= SecureRandom.urlsafe_base64.to_s
  end

  def page
    @page ||= Page.find(payload[:page_id])
  end

  def assigns
    {
      token: token,
      email: email,
      name: payload[:name],
      page: page
    }
  end

  def html(version)
    EmailRenderer.render(assigns, "confirm_action_#{version}.#{page.language_code}.html")
  end

  def text(version)
    EmailRenderer.render(assigns, "confirm_action_#{version}.#{page.language_code}.text")
  end
end

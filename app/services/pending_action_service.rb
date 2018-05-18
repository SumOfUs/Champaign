# frozen_string_literal: true

class PendingActionService
  attr_reader :email, :payload

  class << self
    def create(payload)
      new(payload).create
    end
  end

  def initialize(payload)
    @payload = payload
  end

  def create
    action = PendingAction.create(
      email: payload[:email],
      data: payload,
      token: token,
      page: page
    )

    if action
      EmailDelivery.send_email(
        action,
        html: html,
        text: text,
        subject: 'Nur noch ein Klick - bitte Teilnahme bestätigen!'
      )
    end

    action
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

  def html
    EmailRenderer.render(assigns, 'confirm_action.html')
  end

  def text
    EmailRenderer.render(assigns, 'confirm_action.text')
  end
end

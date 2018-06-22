# frozen_string_literal: true

class PendingActionService
  class Reminders
    class << self
      def send
        actions = PendingAction
          .limit(10)
          .not_confirmed
          .only_emailed_once
          .not_emailed_last_24

        actions.each do |action|
          next if Member.where(consented: true, email: action.email).any?

          assigns = {
            token: action.token,
            email: action.email,
            name: action.data['name'],
            page: action.page,
            locale: action.page.language_code
          }

          options = {
            html: html(assigns),
            text: text(assigns),
            subject: I18n.t('double_opt_in.email.subject', locale: assigns[:locale])
          }

          PendingActionService::EmailDelivery.send_email(action, options)
        end
      end

      def html(assigns)
        PendingActionService::EmailRenderer.render(assigns, "reminder.#{assigns[:locale]}.html")
      end

      def text(assigns)
        PendingActionService::EmailRenderer.render(assigns, "reminder.#{assigns[:locale]}.text")
      end
    end
  end
end

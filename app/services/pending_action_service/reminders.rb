# frozen_string_literal: true

class PendingActionService
  class Reminders
    class << self
      def send
        PendingAction
          .limit(10)
          .not_confirmed
          .only_emailed_once
          .not_emailed_last_24.each do |action|
            assigns = {
              token: action.token,
              email: action.email,
              name: action.data['name'],
              page: Page.find(action.data['page_id'])
            }

            EmailDelivery.send_email(action, html: html(assigns),
                                             text: text(assigns),
                                             subject: I18n.t('double_opt_in.email.subject', locale: :de))
          end
      end

      def html(assigns)
        EmailRenderer.render(assigns, 'confirm_action.html')
      end

      def text(assigns)
        EmailRenderer.render(assigns, 'confirm_action.text')
      end
    end
  end
end

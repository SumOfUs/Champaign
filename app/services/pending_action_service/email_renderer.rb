# frozen_string_literal: true

class PendingActionService
  class EmailRenderer
    def self.render(assigns, template)
      renderer = ApplicationController.renderer.new(
        http_host: Settings.host,
        https: Rails.env.production?
      )

      renderer.render(
        template: "pending_action_mailer/#{template}",
        layout: nil,
        assigns: assigns
      )
    end
  end
end

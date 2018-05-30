# frozen_string_literal: true

class PendingActionService
  class EmailDelivery
    def self.send_email(action, html:, text:, subject:)
      # Post to AWS topic.
      message = {
        to: action.email,
        html: html,
        text: text,
        subject: subject,
        record_id: action.id,
        service: 'DoubleOptIn'
      }

      sns = Aws::SNS::Client.new(region: Settings.aws_region, stub_responses: Rails.env.test?)

      sns.publish(
        message: message.to_json,
        topic_arn: "arn:aws:sns:#{Settings.aws_region}:#{Settings.aws_id}:#{Settings.mailer_topic_id}"
      )

      action.update(email_count: (action.email_count || 0) + 1, emailed_at: Time.now)
    end
  end
end

# frozen_string_literal: true

class PendingActionService
  class EmailDelivery
    def self.send_email(action, html:, text:, subject:)
      # post to AWS topic to be ready by lambda for email sending
      message = {
        to: action.email,
        html: html,
        text: text,
        subject: subject
      }

      sns = Aws::SNS::Client.new(region: Settings.aws_region, stub_responses: Rails.env.test?)

      begin
        sns.publish(
          message: message.to_json,
          topic_arn: Settings.mailer_topic_arn
        )

        action.update(email_count: (action.email_count || 0) + 1, emailed_at: Time.now)
      rescue Aws::SNS::Errors::ServiceError => e
        puts 'ERROR'
        puts e
        # rescues all errors returned by Amazon Simple Notification Service
      end
    end
  end
end

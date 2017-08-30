# frozen_string_literal: true

class EmailSender
  include ActionView::Helpers::TextHelper

  attr_reader :opts

  def self.run(opts)
    new(opts).run
  end

  def initialize(opts)
    @opts = opts
  end

  def run
    dynamodb_client.put_item(table_name: 'UserMailing',
                             item: {
                               MailingId: "#{opts[:page_slug]}:#{Time.now.to_i}",
                               UserId: opts[:from_email],
                               Body: simple_format(opts[:body]),
                               Subject: opts[:subject],
                               ToName: opts[:to_name],
                               ToEmail: opts[:to_email],
                               TargetName: opts[:target_name],
                               Country: opts[:country],
                               FromName: opts[:from_name],
                               FromEmail: opts[:from_email],
                               SourceEmail: opts[:source_email]
                             })
  end

  private

  def dynamodb_client
    @dynamodb ||= Aws::DynamoDB::Client.new(region: 'us-west-2')
  end
end

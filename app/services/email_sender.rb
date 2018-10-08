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
    validate_fields!

    item = {
      MailingId: "#{opts[:id]}:#{Time.now.to_i}",
      Slug: opts[:id],
      UserId: opts[:from_email],
      CreatedAt: Time.now.utc.iso8601,
      Body: opts[:body],
      Subject: opts[:subject],
      Recipients: opts[:recipients],
      Sender: { name: opts[:from_name], email: opts[:from_email] },
      ReplyTo: opts[:reply_to]
    }

    dynamodb_client.put_item(
      table_name: Settings.dynamodb_mailer_table,
      item: item
    )
  end

  private

  def dynamodb_client
    @dynamodb ||= Aws::DynamoDB::Client.new(region: 'us-west-2')
  end

  def validate_fields!
    required_fields = %i[id from_email body from_name from_email recipients]
    blank_fields = required_fields.select { |f| opts[f].blank? }
    if blank_fields.any?
      raise ArgumentError, "The following fields are blank but are required: #{blank_fields.join(',')}"
    end
  end
end

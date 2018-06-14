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
    dynamodb_client.put_item(
      table_name: Settings.dynamodb_mailer_table,
      item: {
        MailingId: "#{opts[:id]}:#{Time.now.to_i}",
        UserId: opts[:from_email],
        Body: opts[:body],
        Subject: opts[:subject],
        ToEmails: format_emails_list(opts[:to]),
        FromName: opts[:from_name],
        FromEmail: opts[:from_email],
        ReplyTo: format_emails_list(opts[:reply_to])
      }
    )
  end

  private

  def format_emails_list(emails)
    list = emails.is_a?(Array) ? emails : [emails]
    list.map { |i| format_email(i[:address], i[:name]) }
  end

  def format_email(address, name)
    if name.present?
      "#{name} <#{address}>"
    else
      address
    end
  end

  def dynamodb_client
    @dynamodb ||= Aws::DynamoDB::Client.new(region: 'us-west-2')
  end

  def validate_fields!
    required_fields = %i[id from_email body to from_name from_email]
    blank_fields = required_fields.select { |f| opts[f].blank? }
    if blank_fields.any?
      raise ArgumentError, "The following fields are blank but are required: #{blank_fields.join(',')}"
    end
  end
end

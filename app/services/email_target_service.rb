# frozen_string_literal: true

class EmailTargetService
  include ActionView::Helpers::TextHelper

  attr_reader :opts

  def initialize(opts)
    @opts = opts
  end

  def create
    EmailTargetService.dynamodb.put_item(options)
  end

  def options
    {
      table_name: 'UserMailing',
      item: {
        MailingId: "#{opts[:page]}:#{Time.now.to_i}",
        UserId: opts[:from_email],
        Body: simple_format(opts[:body]),
        Subject: opts[:subject],
        ToName: opts[:to_name],
        ToEmail: to_email,
        TargetName: opts[:target_name],
        Country: opts[:country],
        FromName: opts[:from_name],
        FromEmail: opts[:from_email],
        SourceEmail: source_email
      }
    }
  end

  def self.dynamodb
    @dynamodb = Aws::DynamoDB::Client.new(region: 'us-west-2')
  end

  private

  def to_email
    test_email.blank? ? opts[:to_email] : test_email
  end

  def source_email
    plugin.email_from
  end

  def test_email
    plugin.test_email_address
  end

  def plugin
    @plugin ||= Plugins::EmailTarget.find_by page_id: page.id
  end

  def page
    @page ||= Page.find_by(slug: opts[:page])
  end
end

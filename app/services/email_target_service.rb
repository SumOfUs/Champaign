# frozen_string_literal: true

class EmailTargetService
  include ActionView::Helpers::TextHelper

  def initialize(page:, to_name:, to_email:, from_name:, from_email:, target_name:, country:, subject:, body:)
    @page = page.to_s
    @body = simple_format(body)
    @subject = subject
    @from_email = from_email
    @from_name = from_name
    @to_email = to_email
    @to_name = to_name
    @target_name = target_name
    @country = country
  end

  def create
    EmailTargetService.dynamodb.put_item(options)
  end


  def options
    {
      table_name: 'UserMailing',
      item: {
        MailingId: "#{@page}:#{Time.now.to_i}",
        UserId: @from_email,
        Body: @body,
        Subject: @subject,
        ToName: @to_name,
        ToEmail: @to_email,
        TargetName: @target_name,
        Country: @country,
        FromName: @from_name,
        FromEmail: @from_email,
        SourceEmail: source_email,
      }
    }
  end

  def source_email
    page = Page.find_by(slug: @page)
    plugin = Plugins::EmailTarget.find_by page_id: page.id
    plugin.email_from
  end

  def self.dynamodb
    @dynamodb = Aws::DynamoDB::Client.new(
      region: 'us-west-2',
    )
  end
end

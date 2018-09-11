# frozen_string_literal: true

class Api::EmailTargetEmailsController < ApplicationController
  before_action :authenticate_user!

  def index
    opts = {
      limit: 100,
      key_condition_expression: '#slug = :slug',
      expression_attribute_names: {
        '#slug' => 'Slug'
      },
      expression_attribute_values: {
        ':slug' => params[:slug]
      },
      index_name: 'Slug-CreatedAt-index',
      scan_index_forward: false,
      table_name: Settings.dynamodb_mailer_table
    }

    if params[:next]
      opts[:exclusive_start_key] = JSON.parse(params[:next])
    end

    resp = dynamodb_client.query(opts)

    render json: {
      items: resp.items,
      next: resp.last_evaluated_key ? resp.last_evaluated_key.to_json : ''
    }
  end

  def download
    message = {
      email: params[:email],
      slug: params[:slug]
    }

    sns = Aws::SNS::Client.new(region: Settings.aws_region, stub_responses: Rails.env.test?)

    sns.publish(
      message: message.to_json,
      topic_arn: topic_arn,
      message_attributes: {
        service: {
          data_type: 'String',
          string_value: 'email_target:download_emails'
        }
      }
    )

    render json: { status: 'ok' }
  end

  private

  def topic_arn
    %W[
      arn:aws:sns
      #{Settings.aws_region}
      #{Settings.aws_account_id}
      champaign-#{Rails.env.production? ? 'prod' : 'dev'}
    ].join(':')
  end

  def dynamodb_client
    @dynamodb ||= Aws::DynamoDB::Client.new(region: 'us-west-2')
  end
end

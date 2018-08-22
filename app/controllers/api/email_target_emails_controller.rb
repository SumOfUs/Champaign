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

  private

  def dynamodb_client
    @dynamodb ||= Aws::DynamoDB::Client.new(region: 'us-west-2')
  end
end

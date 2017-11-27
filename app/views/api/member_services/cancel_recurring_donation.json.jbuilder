# frozen_string_literal: true
@record = @donations_updater.resource

json.recurring_donation do
  json.provider 'braintree' #TODO: add logic for GC
  json.id @record.subscription_id
  json.created_at @record.created_at
  json.cancelled_at @record.cancelled_at
  json.amount @record.amount
  json.currency @record.currency
end

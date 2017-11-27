# frozen_string_literal: true
record = @donations_updater.resource
subscription_id = @provider == 'braintree' ? record.subscription_id : record.go_cardless_id

json.recurring_donation do
  json.provider @provider
  json.id subscription_id
  json.created_at record.created_at
  json.cancelled_at record.cancelled_at
  json.amount record.amount
  json.currency record.currency
end

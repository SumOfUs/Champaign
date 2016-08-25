json.array! @subscriptions do |subscription|
  json.(subscription, :id, :billing_day_of_month, :created_at, :amount)
  json.payment_method subscription.payment_method, :instrument_type, :token, :last_4, :bin, :expiration_date, :email, :card_type
  json.transactions subscription.transactions, :id, :status, :amount, :created_at
end

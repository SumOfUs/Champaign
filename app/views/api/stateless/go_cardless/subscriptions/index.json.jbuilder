# frozen_string_literal: true
json.array! @subscriptions do |subscription|
  json.call(subscription, :id, :go_cardless_id, :amount, :currency, :name, :created_at)
  json.state subscription.aasm_state
  json.payment_method subscription.payment_method, :id, :go_cardless_id, :scheme, :next_possible_charge_date, :created_at
  json.transactions subscription.transactions do |transaction|
    json.id transaction.id
    json.go_cardless_id transaction.go_cardless_id
    json.charge_date transaction.charge_date
    json.state transaction.aasm_state
  end
end

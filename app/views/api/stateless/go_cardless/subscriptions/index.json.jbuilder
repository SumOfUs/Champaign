json.array! @subscriptions do |subscription|
  json.(subscription, :id, :go_cardless_id, :amount, :currency, :name, :aasm_state, :created_at)
  json.payment_method subscription.payment_method, :id, :go_cardless_id, :scheme, :next_possible_charge_date, :created_at
  json.transactions subscription.transactions, :id, :go_cardless_id, :charge_date, :aasm_state
end

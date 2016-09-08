# frozen_string_literal: true
json.array! @transactions do |transaction|
  json.call(transaction, :id, :go_cardless_id, :charge_date, :amount, :description, :currency, :aasm_state)
  json.payment_method transaction.payment_method, :id, :go_cardless_id, :scheme, :next_possible_charge_date, :created_at
end

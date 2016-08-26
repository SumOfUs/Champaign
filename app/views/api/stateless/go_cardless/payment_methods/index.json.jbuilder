json.array! @payment_methods do |method|
  json.(method, :id, :go_cardless_id, :scheme, :next_possible_charge_date, :created_at)
end

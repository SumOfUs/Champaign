json.array! @payment_methods do |method|
  json.(method, :instrument_type, :token, :last_4, :bin, :expiration_date, :email, :card_type)
end

json.array! @transactions do |transaction|
  json.(transaction, :id, :status, :amount, :created_at)
  json.payment_method transaction.payment_method, :instrument_type, :token, :last_4, :bin, :expiration_date, :email, :card_type
end

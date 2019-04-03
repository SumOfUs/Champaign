# frozen_string_literal: true

json.array! @payment_methods do |method|
  json.call(method, :id, :instrument_type, :token, :last_4, :bin, :expiration_date, :email, :card_type)
end

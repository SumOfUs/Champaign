# frozen_string_literal: true

json.array! @transactions do |transaction|
  json.call transaction,
            :id,
            :status,
            :amount,
            :created_at

  json.payment_method transaction.payment_method,
                      :id,
                      :instrument_type,
                      :token,
                      :last_4,
                      :bin,
                      :expiration_date,
                      :email,
                      :card_type
end

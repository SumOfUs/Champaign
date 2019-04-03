# frozen_string_literal: true

json.array! @subscriptions do |subscription|
  json.call subscription,
            :id,
            :billing_day_of_month,
            :created_at,
            :amount,
            :currency

  if subscription.payment_method
    json.payment_method subscription.payment_method,
                        :id,
                        :instrument_type,
                        :token,
                        :last_4,
                        :bin,
                        :expiration_date,
                        :email,
                        :card_type
  else
    json.payment_method nil
  end

  json.transactions subscription.transactions,
                    :id,
                    :status,
                    :amount,
                    :created_at
end

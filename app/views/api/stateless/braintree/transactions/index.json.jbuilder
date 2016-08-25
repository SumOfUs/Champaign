# frozen_string_literal: true
json.array! @transactions do |transaction|
  json.call(transaction, :id, :status, :amount, :created_at)
end

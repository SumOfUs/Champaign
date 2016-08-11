json.array! @transactions do |transaction|
  json.(transaction, :id, :status, :amount, :created_at)
end

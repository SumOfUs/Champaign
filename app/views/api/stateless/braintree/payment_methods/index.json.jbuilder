json.array! @payment_methods do |method|
<<<<<<< HEAD
  json.(method, :instrument_type, :token, :last_4, :bin, :expiration_date, :email)
=======
  json.token 
>>>>>>> 4f53a2d... Partial attempt at refactoring payment method creation
end


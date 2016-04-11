namespace :champaign do
  desc "Create braintree payment method tokens out of existing token columns"
  task braintree_tokens: :environment do
    Payment::BraintreeCustomer.all.each do |customer|
      Payment::BraintreePaymentMethod.create!({customer_id: customer.customer_id, token: customer.card_vault_token})
    end
  end
end

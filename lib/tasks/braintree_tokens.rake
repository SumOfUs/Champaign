# frozen_string_literal: true
namespace :champaign do
  desc 'Create braintree payment method tokens out of existing token columns'
  task braintree_tokens: :environment do
    Payment::BraintreeCustomer.all.each do |customer|
      Payment::BraintreePaymentMethod.create!(customer_id: customer.id, token: customer.card_vault_token)
    end
  end
end

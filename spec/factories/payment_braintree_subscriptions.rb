FactoryGirl.define do
  factory :payment_braintree_subscription, class: 'Payment::Braintree::Subscription' do
    subscription_id { "s#{Faker::Number.number(4)}" }
    amount 79.41
    currency "GBP"
    merchant_account_id "GBP"
  end
end

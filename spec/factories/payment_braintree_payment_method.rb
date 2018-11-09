# frozen_string_literal: true
FactoryBot.define do
  factory :payment_braintree_payment_method, class: 'Payment::Braintree::PaymentMethod' do
    customer_id { Faker::Number.number(6) }
    token 'MyString'
    last_4 '1234'
    expiration_date '12/2050'
    trait :stored do
      store_in_vault true
    end

    trait :paypal do
      instrument_type 'paypal_account'
    end
  end
end

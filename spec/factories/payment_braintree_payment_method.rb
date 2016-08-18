# frozen_string_literal: true
FactoryGirl.define do
  factory :payment_braintree_payment_method, class: 'Payment::Braintree::PaymentMethod' do
    customer_id { Faker::Number.number(6) }
    token 'MyString'
  end
end

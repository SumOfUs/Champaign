FactoryGirl.define do
  factory :braintree_payment_method, :class => 'Payment::BraintreePaymentMethod' do
    customer_id { Faker::Number.number(6) }
    token "MyString"
  end
end

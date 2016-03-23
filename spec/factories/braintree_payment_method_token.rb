FactoryGirl.define do
  factory :braintree_payment_method_token, :class => 'Payment::BraintreePaymentMethodToken' do
    payment_braintree_customer_id { Faker::Number.number(6) }
    braintree_payment_method_token "MyString"
  end
end

FactoryGirl.define do
  factory :braintree_payment_method_token, :class => 'Payment::BraintreePaymentMethodToken' do
    braintree_customer_id { Faker::Number.number(2) }
    braintree_payment_method_token "MyString"
  end
end

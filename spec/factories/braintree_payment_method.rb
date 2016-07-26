FactoryGirl.define do
  factory :braintree_payment_method, :class => 'Payment::Braintree::PaymentMethod' do
    customer_id { Faker::Number.number(6) }
    token "MyString"
  end
end

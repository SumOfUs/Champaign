FactoryGirl.define do
  factory :payment_braintree_transaction, :class => 'Payment::Braintree::Transaction' do
    transaction_id { "t#{Faker::Number.number(4)}" }
    transaction_type "credit_card"
    status 0
    amount 12.34
    transaction_created_at "2015-11-17 16:46:19"
    payment_method_id { "asdf#{Faker::Number.number(10)}" }
    customer_id { Faker::Number.number(4) }
  end
end

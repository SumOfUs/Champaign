FactoryGirl.define do
  factory :payment_braintree_transaction, :class => 'Payment::BraintreeTransaction' do
    transaction_id "MyString"
transaction_type "MyString"
status "MyString"
amount "MyString"
transaction_created_at "2015-11-17 16:46:19"
payment_method_token "MyString"
customer_id "MyString"
  end

end

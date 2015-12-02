FactoryGirl.define do
  factory :payment_braintree_subscription, :class => 'Payment::BraintreeSubscription' do
    subscription_id "MyString"
next_billing_date "2015-12-02 17:27:01"
plan_id "MyString"
price "MyString"
status "MyString"
merchant_account_id "MyString"
customer_id "MyString"
  end

end

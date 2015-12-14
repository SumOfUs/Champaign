FactoryGirl.define do
  factory :payment_braintree_customer, :class => 'Payment::BraintreeCustomer' do
    card_type "MyString"
    card_bin ""
    cardholder_name "MyString"
    card_debit "MyString"
    card_last_4 "MyString"
    default_payment_method_token "MyString"
    card_unqiue_number_identifier "MyString"
    email { Faker::Internet.email }
    first_name "MyString"
    last_name "MyString"
    customer_id "MyString"
  end
end

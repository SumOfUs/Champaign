FactoryGirl.define do
  factory :payment_braintree_customer, :class => 'Payment::BraintreeCustomer' do
    card_type "MyString"
    card_bin ""
    cardholder_name "MyString"
    card_debit "MyString"
    card_last_4 "MyString"
    card_vault_token "MyString"
    card_unqiue_number_identifier "MyString"
    email { Faker::Internet.email }
    full_name "MyString McCoy Richards"
    customer_id "MyString"
  end
end

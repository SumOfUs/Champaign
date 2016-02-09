FactoryGirl.define do
  factory :payment_braintree_customer, :class => 'Payment::BraintreeCustomer' do
    card_type { Faker::Business.credit_card_type }
    card_bin ""
    cardholder_name { Faker::Name.name }
    card_debit "MyString"
    card_last_4 { Faker::Number.number(4) }
    card_vault_token "MyString"
    card_unqiue_number_identifier "MyString"
    email { Faker::Internet.email }
    first_name "MyString"
    last_name "MyString"
    customer_id { Faker::Number.number(6) }
  end
end

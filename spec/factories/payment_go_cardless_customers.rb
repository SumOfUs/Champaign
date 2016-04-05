FactoryGirl.define do
  factory :payment_go_cardless_customer, class: 'Payment::GoCardless::Customer' do
    go_cardless_id { "CU#{Faker::Number.number(6)}" }
    email { Faker::Internet.email }
    country_code 'GB'
    language 'en'
  end
end

FactoryGirl.define do
  factory :payment_go_cardless_transaction, class: 'Payment::GoCardless::Transaction' do
    go_cardless_id { "PM#{Faker::Number.number(6)}" }
    amount 23.19
    currency "EUR"
    status :submitted
  end
end

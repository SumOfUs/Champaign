FactoryGirl.define do
  factory :payment_go_cardless_payment_method, class: 'Payment::GoCardless::PaymentMethod' do
    go_cardless_id { "MD#{Faker::Number.number(6)}" }
    scheme { ['bacs', 'sepa_core'].sample }
  end
end

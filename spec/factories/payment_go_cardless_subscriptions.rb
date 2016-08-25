# frozen_string_literal: true
FactoryGirl.define do
  factory :payment_go_cardless_subscription, class: 'Payment::GoCardless::Subscription' do
    go_cardless_id { "SU#{Faker::Number.number(6)}" }
    amount 33.12
    currency 'GBP'
    status :active
  end
end

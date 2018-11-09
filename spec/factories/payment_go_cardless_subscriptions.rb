# frozen_string_literal: true
# == Schema Information
#
# Table name: payment_go_cardless_subscriptions
#
#  id                :integer          not null, primary key
#  go_cardless_id    :string
#  amount            :decimal(, )
#  currency          :string
#  status            :integer
#  name              :string
#  payment_reference :string
#  page_id           :integer
#  action_id         :integer
#  payment_method_id :integer
#  customer_id       :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  aasm_state        :string
#  cancelled_at      :datetime
#

FactoryBot.define do
  factory :payment_go_cardless_subscription, class: 'Payment::GoCardless::Subscription' do
    go_cardless_id { "SU#{Faker::Number.number(6)}" }
    amount 33.12
    currency 'GBP'
    status :active
    cancelled_at nil
  end
end

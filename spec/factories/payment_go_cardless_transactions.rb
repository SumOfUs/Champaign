# frozen_string_literal: true

# == Schema Information
#
# Table name: payment_go_cardless_transactions
#
#  id                :integer          not null, primary key
#  go_cardless_id    :string
#  charge_date       :date
#  amount            :decimal(, )
#  description       :string
#  currency          :string
#  status            :integer
#  reference         :string
#  amount_refunded   :decimal(, )
#  page_id           :integer
#  payment_method_id :integer
#  customer_id       :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  aasm_state        :string
#  subscription_id   :integer
#

FactoryBot.define do
  factory :payment_go_cardless_transaction, class: 'Payment::GoCardless::Transaction' do
    go_cardless_id { "PM#{Faker::Number.number(6)}" }
    amount { 23.19 }
    currency { 'EUR' }
    status { :submitted }
  end
end

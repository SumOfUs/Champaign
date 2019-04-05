# frozen_string_literal: true

# == Schema Information
#
# Table name: payment_go_cardless_transactions
#
#  id                :integer          not null, primary key
#  aasm_state        :string
#  amount            :decimal(, )
#  amount_refunded   :decimal(, )
#  charge_date       :date
#  currency          :string
#  description       :string
#  reference         :string
#  status            :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  customer_id       :integer
#  go_cardless_id    :string
#  page_id           :integer
#  payment_method_id :integer
#  subscription_id   :integer
#
# Indexes
#
#  go_cardless_transaction_subscription                         (subscription_id)
#  index_payment_go_cardless_transactions_on_customer_id        (customer_id)
#  index_payment_go_cardless_transactions_on_page_id            (page_id)
#  index_payment_go_cardless_transactions_on_payment_method_id  (payment_method_id)
#
# Foreign Keys
#
#  fk_rails_...  (customer_id => payment_go_cardless_customers.id)
#  fk_rails_...  (page_id => pages.id)
#  fk_rails_...  (payment_method_id => payment_go_cardless_payment_methods.id)
#

FactoryBot.define do
  factory :payment_go_cardless_transaction, class: 'Payment::GoCardless::Transaction' do
    go_cardless_id { "PM#{Faker::Number.number(6)}" }
    amount { 23.19 }
    currency { 'USD' }
    status { :submitted }
    association :page, factory: :page

    trait :with_subscription do
      association :subscription, factory: :payment_go_cardless_subscription
    end
  end
end

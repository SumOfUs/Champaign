# frozen_string_literal: true

# == Schema Information
#
# Table name: payment_go_cardless_subscriptions
#
#  id                :integer          not null, primary key
#  aasm_state        :string
#  amount            :decimal(, )
#  cancelled_at      :datetime
#  currency          :string
#  name              :string
#  payment_reference :string
#  status            :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  action_id         :integer
#  customer_id       :integer
#  go_cardless_id    :string
#  page_id           :integer
#  payment_method_id :integer
#
# Indexes
#
#  index_payment_go_cardless_subscriptions_on_action_id          (action_id)
#  index_payment_go_cardless_subscriptions_on_customer_id        (customer_id)
#  index_payment_go_cardless_subscriptions_on_page_id            (page_id)
#  index_payment_go_cardless_subscriptions_on_payment_method_id  (payment_method_id)
#
# Foreign Keys
#
#  fk_rails_...  (action_id => actions.id)
#  fk_rails_...  (customer_id => payment_go_cardless_customers.id)
#  fk_rails_...  (page_id => pages.id)
#  fk_rails_...  (payment_method_id => payment_go_cardless_payment_methods.id)
#

FactoryBot.define do
  factory :payment_go_cardless_subscription, class: 'Payment::GoCardless::Subscription' do
    go_cardless_id { "SU#{Faker::Number.number(6)}" }
    amount { 33.12 }
    currency { 'USD' }
    status { :active }
    cancelled_at { nil }
  end
end

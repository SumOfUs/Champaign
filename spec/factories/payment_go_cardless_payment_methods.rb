# frozen_string_literal: true

# == Schema Information
#
# Table name: payment_go_cardless_payment_methods
#
#  id                        :integer          not null, primary key
#  aasm_state                :string
#  cancelled_at              :datetime
#  next_possible_charge_date :date
#  reference                 :string
#  scheme                    :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  customer_id               :integer
#  go_cardless_id            :string
#
# Indexes
#
#  index_payment_go_cardless_payment_methods_on_customer_id  (customer_id)
#
# Foreign Keys
#
#  fk_rails_...  (customer_id => payment_go_cardless_customers.id)
#

FactoryBot.define do
  factory :payment_go_cardless_payment_method, class: 'Payment::GoCardless::PaymentMethod' do
    go_cardless_id { "MD#{Faker::Number.number(6)}" }
    scheme { %w[bacs sepa_core].sample }
    cancelled_at { nil }
  end
end

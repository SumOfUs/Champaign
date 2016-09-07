# frozen_string_literal: true
# == Schema Information
#
# Table name: payment_go_cardless_payment_methods
#
#  id                        :integer          not null, primary key
#  go_cardless_id            :string
#  reference                 :string
#  scheme                    :string
#  next_possible_charge_date :date
#  customer_id               :integer
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  aasm_state                :string
#

FactoryGirl.define do
  factory :payment_go_cardless_payment_method, class: 'Payment::GoCardless::PaymentMethod' do
    go_cardless_id { "MD#{Faker::Number.number(6)}" }
    scheme { %w(bacs sepa_core).sample }
    cancelled_at nil
  end
end

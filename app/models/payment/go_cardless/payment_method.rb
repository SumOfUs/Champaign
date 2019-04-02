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

class Payment::GoCardless::PaymentMethod < ApplicationRecord
  include AASM

  ACTION_FROM_STATE = {
    created: :create,
    submitted: :submit,
    active: :activate,
    cancelled: :cancel,
    expired: :expire
  }.freeze

  aasm do
    state :pending, initial: true
    state :created
    state :submitted
    state :active
    state :cancelled
    state :expired

    event :run_create do
      transitions from: [:pending], to: :created
    end

    event :run_submit do
      transitions from: %i[pending created], to: :submitted
    end

    event :run_activate do
      transitions from: %i[pending created submitted], to: :active
    end

    event :run_cancel do
      transitions from: [:active], to: :cancelled
    end

    event :run_expire do
      transitions from: [:active], to: :expired
    end
  end

  belongs_to :customer, class_name: 'Payment::GoCardless::Customer'

  validates :go_cardless_id, presence: true, allow_blank: false
  scope :active, -> { where(cancelled_at: nil) }
end

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
#  cancelled_at              :datetime
#

class Payment::GoCardless::PaymentMethod < ActiveRecord::Base
  include AASM

  ACTION_FROM_STATE = {
    created:    :create,
    submitted:  :submit,
    active:     :activate,
    cancelled:  :cancel,
    expired:    :expire
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
      transitions from: [:pending, :created], to: :submitted
    end

    event :run_activate do
      transitions from: [:pending, :created, :submitted], to: :active
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

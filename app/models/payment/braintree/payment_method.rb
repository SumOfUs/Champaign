# frozen_string_literal: true
# == Schema Information
#
# Table name: payment_braintree_payment_methods
#
#  id              :integer          not null, primary key
#  token           :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  customer_id     :integer
#  card_type       :string
#  bin             :string
#  cardholder_name :string
#  last_4          :string
#  expiration_date :string
#  instrument_type :string
#  email           :string
#  store_in_vault  :boolean          default(FALSE)
#  cancelled_at    :datetime
#

class Payment::Braintree::PaymentMethod < ApplicationRecord
  belongs_to :customer, class_name: 'Payment::Braintree::Customer'

  has_many   :subscriptions, class_name: 'Payment::Braintree::Subscription',
                             foreign_key: 'payment_method_id'

  has_many   :transactions, class_name: 'Payment::Braintree::Transaction',
                            foreign_key: 'payment_method_id'

  scope :stored, -> { where(store_in_vault: true) }
  scope :active, -> { where(cancelled_at: nil) }
end

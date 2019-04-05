# frozen_string_literal: true

# == Schema Information
#
# Table name: payment_braintree_payment_methods
#
#  id              :integer          not null, primary key
#  bin             :string
#  cancelled_at    :datetime
#  card_type       :string
#  cardholder_name :string
#  email           :string
#  expiration_date :string
#  instrument_type :string
#  last_4          :string
#  store_in_vault  :boolean          default(FALSE)
#  token           :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  customer_id     :integer
#
# Indexes
#
#  braintree_customer_index                                   (customer_id)
#  index_payment_braintree_payment_methods_on_store_in_vault  (store_in_vault)
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

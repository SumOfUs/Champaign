# frozen_string_literal: true
# == Schema Information
#
# Table name: payment_braintree_payment_methods
#
#  id          :integer          not null, primary key
#  token       :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  customer_id :integer
#

class Payment::Braintree::PaymentMethod < ActiveRecord::Base
  belongs_to :customer, class_name: 'Payment::Braintree::Customer'

  has_many   :subscriptions, class_name: 'Payment::Braintree::Subscription',
                             foreign_key: 'payment_method_id'

  has_many   :transactions, class_name: 'Payment::Braintree::Transaction',
                            foreign_key: 'payment_method_id'

  scope :stored, -> { where(store_in_vault: true) }
end

# frozen_string_literal: true
class Payment::Braintree::PaymentMethod < ActiveRecord::Base
  belongs_to :customer,     class_name: 'Payment::Braintree::Customer'
  has_many   :transactions, class_name: 'Payment::Braintree::Transaction', foreign_key: 'payment_method_id'
end

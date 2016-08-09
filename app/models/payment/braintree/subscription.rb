# frozen_string_literal: true
class Payment::Braintree::Subscription < ActiveRecord::Base
  belongs_to :page
  belongs_to :action
  belongs_to :customer,     class_name: 'Payment::Braintree::Customer', primary_key: 'customer_id', foreign_key: 'customer_id'
  has_many   :transactions, class_name: 'Payment::Braintree::Transaction', foreign_key: :subscription_id
end

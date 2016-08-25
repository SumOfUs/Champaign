# frozen_string_literal: true
class Payment::Braintree::Subscription < ActiveRecord::Base
  belongs_to :page
  belongs_to :action
  has_many   :transactions, class_name: 'Payment::Braintree::Transaction', foreign_key: :subscription_id
end

# frozen_string_literal: true
class Payment::Braintree::Customer < ActiveRecord::Base
  belongs_to :member
  has_many   :payment_methods,  class_name: 'Payment::Braintree::PaymentMethod',
                                foreign_key: 'customer_id'
  has_many   :subscriptions,    class_name: 'Payment::Braintree::Subscription',
                                foreign_key: 'customer_id',
                                primary_key: 'customer_id'
  has_many   :transactions,     class_name: 'Payment::Braintree::Transaction',
                                foreign_key: 'customer_id',
                                primary_key: 'customer_id'

  def default_payment_method
    payment_methods.order('created_at desc').first
  end
end

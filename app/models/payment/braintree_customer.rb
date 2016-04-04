class Payment::BraintreeCustomer < ActiveRecord::Base
  belongs_to :member
  has_many   :payment_methods, class_name: Payment::BraintreePaymentMethod, foreign_key: 'customer_id'

  def default_payment_method
    payment_methods.order('created_at desc').first
  end
end

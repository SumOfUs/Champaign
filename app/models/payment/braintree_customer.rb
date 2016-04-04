class Payment::BraintreeCustomer < ActiveRecord::Base
  belongs_to :member
  has_many :braintree_payment_methods, class_name: Payment::BraintreePaymentMethod, primary_key: :customer_id, foreign_key: :customer_id


  def default_payment_method
    braintree_payment_methods.order('created_at desc').first
  end
end

# frozen_string_literal: true
# == Schema Information
#
# Table name: payment_braintree_customers
#
#  id                            :integer          not null, primary key
#  card_type                     :string
#  card_bin                      :string
#  cardholder_name               :string
#  card_debit                    :string
#  card_last_4                   :string
#  card_vault_token              :string
#  card_unique_number_identifier :string
#  email                         :string
#  first_name                    :string
#  last_name                     :string
#  customer_id                   :string
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  member_id                     :integer
#

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

  def valid_payment_method_id(token)
    payment_methods
      .stored
      .active
      .where(token: token)
      .order('created_at DESC')
      .first
      &.id
  end
end

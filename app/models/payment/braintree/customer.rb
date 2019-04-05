# frozen_string_literal: true

# == Schema Information
#
# Table name: payment_braintree_customers
#
#  id                            :integer          not null, primary key
#  card_bin                      :string
#  card_debit                    :string
#  card_last_4                   :string
#  card_type                     :string
#  card_unique_number_identifier :string
#  card_vault_token              :string
#  cardholder_name               :string
#  email                         :string
#  first_name                    :string
#  last_name                     :string
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  customer_id                   :string
#  member_id                     :integer
#
# Indexes
#
#  index_payment_braintree_customers_on_member_id  (member_id)
#
# Foreign Keys
#
#  fk_rails_...  (member_id => members.id)
#

class Payment::Braintree::Customer < ApplicationRecord
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

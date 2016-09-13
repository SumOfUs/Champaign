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
  has_many   :payment_methods, class_name: 'Payment::Braintree::PaymentMethod', foreign_key: 'customer_id'

  def default_payment_method
    payment_methods.order('created_at desc').first
  end
end

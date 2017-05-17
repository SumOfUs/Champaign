# frozen_string_literal: true
# == Schema Information
#
# Table name: payment_go_cardless_customers
#
#  id             :integer          not null, primary key
#  go_cardless_id :string
#  email          :string
#  given_name     :string
#  family_name    :string
#  postal_code    :string
#  country_code   :string
#  language       :string
#  member_id      :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class Payment::GoCardless::Customer < ApplicationRecord
  belongs_to :member

  has_many :payment_methods, class_name: 'Payment::GoCardless::PaymentMethod'
  has_many :transactions, class_name: 'Payment::GoCardless::Transaction'
  has_many :subscriptions, class_name: 'Payment::GoCardless::Subscription'

  validates :go_cardless_id, presence: true, allow_blank: false
end

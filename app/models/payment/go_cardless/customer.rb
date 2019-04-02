# frozen_string_literal: true

# == Schema Information
#
# Table name: payment_go_cardless_customers
#
#  id             :integer          not null, primary key
#  country_code   :string
#  email          :string
#  family_name    :string
#  given_name     :string
#  language       :string
#  postal_code    :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  go_cardless_id :string
#  member_id      :integer
#
# Indexes
#
#  index_payment_go_cardless_customers_on_member_id  (member_id)
#
# Foreign Keys
#
#  fk_rails_...  (member_id => members.id)
#

class Payment::GoCardless::Customer < ApplicationRecord
  belongs_to :member

  has_many :payment_methods, class_name: 'Payment::GoCardless::PaymentMethod'
  has_many :transactions, class_name: 'Payment::GoCardless::Transaction'
  has_many :subscriptions, class_name: 'Payment::GoCardless::Subscription'

  validates :go_cardless_id, presence: true, allow_blank: false
end

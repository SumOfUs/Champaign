# frozen_string_literal: true

# == Schema Information
#
# Table name: payment_braintree_local_payment_transactions
#
#  id         :bigint(8)        not null, primary key
#  data       :jsonb
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  page_id    :string
#  payment_id :string
#
# Indexes
#
#  index_local_payment_transactions_on_payment_id  (payment_id)
#

#
# Indexes
#
# Foreign Keys
#

class Payment::Braintree::LocalPaymentTransaction < ApplicationRecord
  belongs_to :page
end

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

require 'rails_helper'

describe Payment::Braintree::Customer do
  describe '#member' do
    let(:member)   { create(:member) }
    let(:customer) { create(:payment_braintree_customer) }

    before do
      customer.update(member: member)
    end

    it 'returns the associated member' do
      expect(customer.member).to eq(member)
    end
  end
end

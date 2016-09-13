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

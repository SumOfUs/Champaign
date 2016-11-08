# frozen_string_literal: true
# == Schema Information
#
# Table name: campaigns
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime
#  updated_at :datetime
#

require 'rails_helper'

describe Campaign do
  describe 'validations' do
  end

  describe '#action_count' do
    let(:campaign) { create(:campaign) }
    let!(:page_a) { create(:page, campaign: campaign, action_count: 5) }
    let!(:page_b) { create(:page, campaign: campaign, action_count: 5) }

    it 'returns sum of counts from associated pages' do
      expect(campaign.action_count).to eq(10)
    end
  end
end

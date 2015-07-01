require 'rails_helper'

describe Campaign do
  describe 'validations' do

  end

  describe 'scopes' do
    describe 'active' do
      #TODO Implement fixtures. FactoryGirl, perheps?
      let(:active_campaign)     { Campaign.create( campaign_name: "I'm active", active: true ) }
      let(:not_active_campaign) { Campaign.create( campaign_name: "I'm not active", active: false ) }

      it 'returns active campaigns' do
        expect(Campaign.active).to eq([active_campaign])
      end
    end
  end
end

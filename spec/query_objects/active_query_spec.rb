require 'rails_helper'

describe ActiveQuery do
  ###### TODO Use factories, once https://github.com/SumOfUs/Champaign/pull/34 is merged.
  let(:active_campaign)     { Campaign.create( campaign_name: "I'm active", active: true ) }
  let(:not_active_campaign) { Campaign.create( campaign_name: "I'm not active", active: false ) }

  it 'returns active campaigns' do
    expect(ActiveQuery.new(Campaign).all).to eq([active_campaign])
  end
end

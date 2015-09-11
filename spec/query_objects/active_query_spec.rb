require 'rails_helper'

describe ActiveQuery do
  let(:active)   { create(:campaign, active: true) }
  let(:inactive) {  create(active: false) }

  it 'returns active campaigns' do
    expect(ActiveQuery.new(Campaign).all).to eq([active])
  end
end

require 'rails_helper'
require_relative 'shared_examples'

describe Plugins::Fundraiser do
  let(:fundraiser) { create :plugins_fundraiser }

  subject{ fundraiser }

  include_examples "plugin with form", :plugins_fundraiser

  it { is_expected.to be_valid }
  it { is_expected.to respond_to :title }
  it { is_expected.to respond_to :ref }
  it { is_expected.to respond_to :page }

  it 'is included in Plugins.registered' do
    expect(Plugins.registered).to include(Plugins::Fundraiser)
  end

  it 'serializes the currency band' do
    allow(PaymentProcessor::Currency).to receive(:convert)
    band = create :donation_band
    fundraiser.donation_band = band
    serialized = fundraiser.liquid_data
    expect(serialized.keys).to include(:form_id, :fields, :donation_bands)
    expect(serialized[:donation_bands].class).to eq String
  end

  it 'serializes without a currency band' do
    expect{ fundraiser.liquid_data }.not_to raise_error
    expect( fundraiser.liquid_data[:donation_bands]).to eq "null"
  end

end

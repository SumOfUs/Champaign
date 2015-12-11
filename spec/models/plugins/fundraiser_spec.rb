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

  it 'serializes a named donation band' do
    allow(PaymentProcessor::Currency).to receive(:convert)
    _ = create :donation_band # We create this because it would be the default if the named band wasn't found.
    second_band = DonationBand.create!(name: 'Test Band', amounts: [100, 200])

    # The converted values of the second band.
    expected_converted_values = second_band.internationalize.to_json
    serialized = fundraiser.liquid_data({url_params: {donation_band: 'Test Band'}})
    expect(serialized[:donation_bands]).to eq(expected_converted_values)
  end

end

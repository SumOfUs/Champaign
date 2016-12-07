# frozen_string_literal: true
# == Schema Information
#
# Table name: plugins_fundraisers
#
#  id                :integer          not null, primary key
#  title             :string
#  ref               :string
#  page_id           :integer
#  active            :boolean          default(FALSE)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  form_id           :integer
#  donation_band_id  :integer
#  recurring_default :integer          default(0), not null
#

require 'rails_helper'
require_relative 'shared_examples'

describe Plugins::Fundraiser do
  let(:fundraiser) { create :plugins_fundraiser }

  subject { fundraiser }

  include_examples 'plugin with form', :plugins_fundraiser

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
    expect(serialized[:donation_bands].class).to eq Hash
  end

  it 'serializes without a currency band' do
    expect { fundraiser.liquid_data }.not_to raise_error
    expect(fundraiser.liquid_data[:donation_bands]).to eq({})
  end

  it 'serializes a named donation band' do
    allow(PaymentProcessor::Currency).to receive(:convert)
    _ = create :donation_band # We create this because it would be the default if the named band wasn't found.
    second_band = DonationBand.create!(name: 'Test Band', amounts: [100, 200])

    # The converted values of the second band.
    expected_converted_values = second_band.internationalize
    serialized = fundraiser.liquid_data(donation_band: 'Test Band')
    expect(serialized[:donation_bands]).to eq(expected_converted_values)
  end

  it 'serializes the recurring_default as its name string' do
    fundraiser.only_recurring!
    expect(fundraiser.liquid_data[:recurring_default]).to eq 'only_recurring'
  end

  describe '.donation_default_for_page' do
    let(:page) { create(:page) }

    context 'without recurring default' do
      it 'determins if recurring for page' do
        create :plugins_fundraiser, page: page, recurring_default: 0
        expect(Plugins::Fundraiser.donation_default_for_page(page.id)).to eq(false)
      end

      it 'is false when there is no page' do
        expect(Plugins::Fundraiser.donation_default_for_page(0)).to eq(false)
      end
    end

    context 'with recurring default' do
      it 'determins if recurring for page' do
        create :plugins_fundraiser, page: page, recurring_default: 1
        expect(Plugins::Fundraiser.donation_default_for_page(page.id)).to eq(true)
      end
    end
  end
end

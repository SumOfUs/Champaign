# frozen_string_literal: true
require 'spec_helper'

describe DonationBandConverter do
  let(:initial_string) { '1 2 3 4 5' }
  let(:duplicate_input) { '1 1 2 3 4 5 5' }
  let(:expected_output) { [1, 2, 3, 4, 5] }

  it 'converts for saving' do
    expect(DonationBandConverter.convert_for_saving(initial_string)).to eq(expected_output)
  end

  it 'removes duplicates' do
    expect(DonationBandConverter.convert_for_saving(duplicate_input)).to eq(expected_output)
  end
end

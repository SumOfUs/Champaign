# frozen_string_literal: true
require 'spec_helper'

describe Donations::Utils do
  subject { Donations::Utils }

  describe '.round' do
    it 'returns only integers' do
      expect(
        subject.round(['1.02', '2.04', '3.02', '4.01', '0.45', '0', '0.00'])
      ).to eq [1, 2, 3, 4, 1, 1, 1]
    end

    it 'rounds values above 20 to the nearest 5' do
      expect(
        subject.round([7.8, 22.5, 26.1, 43, 51.001])
      ).to eq [8, 25, 25, 45, 50]
    end

    it 'rounds values below 20 to the nearest 1' do
      expect(
        subject.round([3.1, 3.5, '4.9', 12.4892, 19.9])
      ).to eq [3, 4, 5, 12, 20]
    end

    it 'handles an empty array' do
      expect(subject.round([])).to eq []
    end

    it 'handles integers' do
      expect(
        subject.round([4, 9, 19, 24, 30])
      ).to eq [4, 9, 19, 25, 30]
    end

    it 'handles many values' do
      expect(
        subject.round([4, 5, 7, 12.2, 199, 31, 100, 6])
      ).to eq [4, 5, 7, 12, 200, 30, 100, 6]
    end
  end

  describe '.deduplicate' do
    it 'sorts them even if nothing changes' do
      expect(
        subject.deduplicate([9, 4, 25, 24, 45])
      ).to eq [4, 9, 24, 25, 45]
    end

    it 'deduplicates below 20 to nearest available 1' do
      expect(
        subject.deduplicate([3, 3, 4, 6, 6])
      ).to eq [3, 4, 5, 6, 7]
    end

    it 'dedeuplicates above 20 to nearest available 5' do
      expect(
        subject.deduplicate([19, 19, 20, 25, 45])
      ).to eq [19, 20, 25, 30, 45]
    end

    it 'dedeuplicates properly even if many matches' do
      expect(
        subject.deduplicate([17, 17, 17, 17, 17])
      ).to eq [17, 18, 19, 20, 25]
    end

    it 'handles an empty array' do
      expect(subject.deduplicate([])).to eq []
    end

    it 'handles floats' do
      expect(
        subject.deduplicate([16.7, 16.7, 20.0, 25.1, 30.1])
      ).to eq [16.7, 17.7, 20.0, 25.1, 30.1]
    end
  end

  describe '.currency_from_country_code' do
    it 'maps european countries to euro' do
      expect(subject.currency_from_country_code('CZ')).to eq 'EUR'
      expect(subject.currency_from_country_code('DE')).to eq 'EUR'
    end

    it 'maps nil to USD' do
      expect(subject.currency_from_country_code(nil)).to eq 'USD'
    end

    it 'maps unknown country to USD' do
      expect(subject.currency_from_country_code('NI')).to eq 'USD'
    end

    it 'maps US to USD' do
      expect(subject.currency_from_country_code('US')).to eq 'USD'
    end

    it 'maps GB to GBP' do
      expect(subject.currency_from_country_code('GB')).to eq 'GBP'
    end

    it 'maps NZ to NZD' do
      expect(subject.currency_from_country_code('NZ')).to eq 'NZD'
    end

    it 'maps AU to AUD' do
      expect(subject.currency_from_country_code('AU')).to eq 'AUD'
    end

    it 'maps CA to CAD' do
      expect(subject.currency_from_country_code('CA')).to eq 'CAD'
    end

    it 'works with symbols' do
      expect(subject.currency_from_country_code(:CA)).to eq 'CAD'
    end
  end
end

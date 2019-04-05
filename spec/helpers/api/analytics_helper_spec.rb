# frozen_string_literal: true

require 'rails_helper'

describe Api::AnalyticsHelper do
  let(:cache) { double(:cache) }

  let(:data) do
    { '2000-01-01 00:00:00' => 3,
      '1999-12-31 00:00:00' => 8 }
  end

  let(:expected_array) do
    [
      { date: '2000-01-01 00:00:00', value: 3 },
      { date: '1999-12-31 00:00:00', value: 8 }
    ]
  end

  before do
    allow(cache).to receive(:total_actions_over_time) { data }
    allow(cache).to receive(:total_new_members_over_time) { data }
  end

  describe '#total_actions_by_hour' do
    it 'fetches data from cache' do
      expect(cache).to receive(:total_actions_over_time).with(period: :hour)
      helper.total_actions_by_hour(cache)
    end

    it 'returns array of data points' do
      expect(helper.total_actions_by_hour(cache)).to eq(expected_array)
    end
  end

  describe '#total_actions_by_day' do
    it 'fetches data from cache' do
      expect(cache).to receive(:total_actions_over_time).with(period: :day)
      helper.total_actions_by_day(cache)
    end

    it 'returns array of data points' do
      expect(helper.total_actions_by_day(cache)).to eq(expected_array)
    end
  end

  describe '#new_members_by_day' do
    it 'fetches data from cache' do
      expect(cache).to receive(:total_new_members_over_time).with(period: :day)
      helper.new_members_by_day(cache)
    end

    it 'returns array of data points' do
      expect(helper.new_members_by_day(cache)).to eq(expected_array)
    end
  end
end

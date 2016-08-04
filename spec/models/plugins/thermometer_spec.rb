require 'rails_helper'

describe Plugins::Thermometer do
  let(:starting_action_count) { 37 }
  let(:liquid_layout) { LiquidLayout.create! title: 'test', content: 'test' }
  let(:page) { Page.create! title: 'test page', action_count: starting_action_count, liquid_layout: liquid_layout }
  let(:thermometer) { Plugins::Thermometer.create! page: page }

  it "can accept random supplemental data to liquid_data method" do
    expect{ thermometer.liquid_data({foo: 'bar'}) }.not_to raise_error
  end

  it 'correctly returns the current total' do
    expect(thermometer.current_total).to eq(starting_action_count)
  end

  it 'correctly returns the correct progress' do
    expect(thermometer.current_progress).to eq 37
    allow(thermometer).to receive(:goal).and_return(2000)
    expect(thermometer.current_progress).to be_within(0.01).of 1.85
  end

  describe "goal serialization" do
    it 'serializes the goal in K notation if equal to 1000' do
      allow(thermometer).to receive(:goal).and_return(1000)
      expect(thermometer.liquid_data[:goal_k]).to eq '1k'
    end

    it 'serializes the goal in K notation if over 1000' do
      allow(thermometer).to receive(:goal).and_return(200000)
      expect(thermometer.liquid_data[:goal_k]).to eq '200k'
    end

    it 'serializes the goal with millions if over 1 million' do
      allow(thermometer).to receive(:goal).and_return(1_500_000)
      expect(thermometer.liquid_data[:goal_k]).to eq '1.5 million'
    end

    it 'serializes the goal in millions translated if language available' do
      page.language = build :language, code: 'de'
      allow(thermometer).to receive(:goal).and_return(1_000_000)
      expect(thermometer.liquid_data[:goal_k]).to eq '1 Millionen'
    end

    it 'serializes the goal as a number if under 1000' do
      allow(thermometer).to receive(:goal).and_return(700)
      expect(thermometer.liquid_data[:goal_k]).to eq '700'
    end
  end

  describe "#goal" do
    it "returns 100 if count is lower than 100" do
      expect(thermometer.goal).to eq 100
    end

    it "returns 20k if count is between 15k and 20k" do
      thermometer.page.action_count = 17_000
      expect(thermometer.goal).to eq 20_000
    end

    it "returns 1.5M if count is between 1M and 1.5M" do
      thermometer.page.action_count = 1_200_000
      expect(thermometer.goal).to eq 1_500_000
    end

    it "returns 9M if count is between 8M and 9M" do
      thermometer.page.action_count = 8_300_000
      expect(thermometer.goal).to eq 9_000_000
    end
  end

  describe "#current_total" do
    context "given the page doesn't belong to a campaign" do
      let!(:page) { create(:page, action_count: 12) }
      let!(:thermometer) { Plugins::Thermometer.create! offset: 10, page: page }

      it "it returns the page action_count + offset" do
        expect(thermometer.current_total).to eq 22
      end
    end

    context "given the page belongs to a campaign" do
      let(:campaign) { create(:campaign) }
      let!(:page) { create(:page, campaign: campaign, action_count: 20) }
      let!(:thermometer) { Plugins::Thermometer.create! offset: 10, page: page }
      before { create(:page, campaign: campaign, action_count: 30) }

      it "consolidates the action counter of all pages of the campaign" do
        expect(thermometer.current_total).to eq 60
      end
    end
  end
end

require 'rails_helper'

describe Plugins::Thermometer do
  let(:starting_action_count) { 37 }
  let(:liquid_layout) { LiquidLayout.create! title: 'test', content: 'test' }
  let(:test_page) { Page.create! title: 'test page', action_count: starting_action_count, liquid_layout: liquid_layout }
  let(:thermometer) { Plugins::Thermometer.create! offset: 0, goal: 100, page: test_page }

  it "can accept random supplemental data to liquid_data method" do
    expect{ thermometer.liquid_data({foo: 'bar'}) }.not_to raise_error
  end

  it 'correctly returns the current total' do
    expect(thermometer.current_total).to eq(starting_action_count)
  end

  it 'correctly returns the correct progress' do
    expect(thermometer.current_progress).to eq 37
    thermometer.update_attributes(goal: 2000)
    expect(thermometer.current_progress).to be_within(0.01).of 1.85
  end

  it 'serializes the goal in K notation if equal to 1000' do
    thermometer.update_attributes(goal: 1000)
    expect(thermometer.liquid_data[:goal_k]).to eq '1k'
  end

  it 'serializes the goal in K notation if over 1000' do
    thermometer.update_attributes(goal: 200000)
    expect(thermometer.liquid_data[:goal_k]).to eq '200k'
  end

  it 'serializes the goal with millions if over 1 million' do
    thermometer.update_attributes(goal: 1_500_000)
    expect(thermometer.liquid_data[:goal_k]).to eq '1.5 million'
  end

  it 'serializes the goal in millions translated if language available' do
    test_page.language = build :language, code: 'de'
    thermometer.update_attributes(goal: 1_000_000)
    expect(thermometer.liquid_data[:goal_k]).to eq '1 Millionen'
  end

  it 'serializes the goal as a number if under 1000' do
    thermometer.update_attributes(goal: 700)
    expect(thermometer.liquid_data[:goal_k]).to eq '700'
  end

  it 'correctly jumps between 100 and 500' do
    test_page.update_attributes(action_count: 101)
    thermometer.update_goal
    expect(thermometer.goal).to eq(200)
  end

  it 'correctly jumps between 500 and 1K' do
    test_page.update_attributes(action_count: 501)
    thermometer.update_goal
    expect(thermometer.goal).to eq(2000)
  end

  it 'correctly jumps between 1K and 10K' do
    test_page.update_attributes(action_count: 1320)
    thermometer.update_goal
    expect(thermometer.goal).to eq(2000)
  end

  it 'correctly jumps between 10K and 25K' do
    test_page.update_attributes(action_count: 10000)
    thermometer.update_goal
    expect(thermometer.goal).to eq(15000)
  end

  it 'correctly jumps between 25K and 100K' do
    test_page.update_attributes(action_count: 25000)
    thermometer.update_goal
    expect(thermometer.goal).to eq(50000)
  end

  it 'correctly jumps between 100K and 250K' do
    test_page.update_attributes(action_count: 120001)
    thermometer.update_goal
    expect(thermometer.goal).to eq(150000)
  end

  it 'correctly jumps between 250K and 1MM' do
    test_page.update_attributes(action_count: 250000)
    thermometer.update_goal
    expect(thermometer.goal).to eq(500000)
  end

  it 'correctly jumps between 1MM and 2MM' do
    test_page.update_attributes(action_count: 1000000)
    thermometer.update_goal
    expect(thermometer.goal).to eq(1500000)
  end

  it 'correctly jumps over 2MM' do
    test_page.update_attributes(action_count: 2000000)
    thermometer.update_goal
    expect(thermometer.goal).to eq(3000000)
  end

  it 'correctly increments the goal even when the number is much higher' do
    expect(thermometer.goal).to eq(100)
    test_page.update_attributes(action_count: 51248)
    thermometer.update_goal
    expect(thermometer.goal).to eq(75000)
  end
end

require 'rails_helper'

describe Plugins::Thermometer do
  let(:starting_action_count) { 999 }
  let(:liquid_layout) { LiquidLayout.create! title: 'test', content: 'test' }
  let(:test_page) { Page.create! title: 'test page', action_count: starting_action_count, liquid_layout: liquid_layout }
  let(:thermometer) { Plugins::Thermometer.create! offset: 0, goal: 1000, page: test_page }

  it 'correctly returns the current total' do
    expect(thermometer.current_total).to eq(starting_action_count)
  end

  it 'correctly returns the correct progress' do
    expect(thermometer.current_progress).to eq(99.9)
  end

  it 'correctly jumps between 100 and 500' do
    test_page.action_count = 101
    test_page.save
    thermometer.update_goal
    expect(thermometer.goal).to eq(1000)
  end

  it 'correctly jumps between 500 and 1K' do
    test_page.action_count = 501
    test_page.save
    thermometer.update_goal
    expect(thermometer.goal).to eq(2000)
  end

  it 'correctly jumps between 1K and 10K' do
    test_page.action_count = 1000
    test_page.save
    thermometer.update_goal
    expect(thermometer.goal).to eq(2000)
  end

  it 'correctly jumps between 10K and 25K' do
    test_page.action_count = 10000
    test_page.save
    thermometer.update_goal
    expect(thermometer.goal).to eq(15000)
  end

  it 'correctly jumps between 25K and 100K' do
    test_page.action_count = 25000
    test_page.save
    thermometer.update_goal
    expect(thermometer.goal).to eq(50000)
  end

  it 'correctly jumps between 100K and 250K' do
    test_page.action_count = 100000
    test_page.save
    thermometer.update_goal
    expect(thermometer.goal).to eq(150000)
  end

  it 'correctly jumps between 250K and 1MM' do
    test_page.action_count = 250000
    test_page.save
    thermometer.update_goal
    expect(thermometer.goal).to eq(500000)
  end

  it 'correctly jumps between 1MM and 2MM' do
    test_page.action_count = 1000000
    test_page.save
    thermometer.update_goal
    expect(thermometer.goal).to eq(1500000)
  end

  it 'correctly jumps over 2MM' do
    test_page.action_count = 2000000
    test_page.save
    thermometer.update_goal
    expect(thermometer.goal).to eq(3000000)
  end

  it 'correctly increments the goal even when the number is much higher' do
    expect(thermometer.goal).to eq(1000)
    test_page.action_count = 51248
    test_page.save
    thermometer.update_goal
    expect(thermometer.goal).to eq(75000)
  end
end

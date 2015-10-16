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

  it 'correctly increments the goal by 12.5% rounded to the nearest 50' do
    test_page.action_count = 1000
    test_page.save
    thermometer.update_goal
    expect(thermometer.goal).to eq(1100)
  end

  it 'correctly increments the goal even when the number is much higher' do
    expect(thermometer.goal).to eq(1000)
    test_page.action_count = 50000
    test_page.save
    thermometer.update_goal
    expect(thermometer.goal).to eq(56250)
  end
end

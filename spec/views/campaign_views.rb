require 'spec_helper'
require 'rails_helper'

describe 'campaigns/new.slim' do
  it 'renders without error' do
    assign :campaign, Campaign.new
    expect{ render }.not_to raise_error
  end
end

describe 'campaigns/edit.slim' do
  it 'renders without error' do
    assign :campaign, build(:campaign, id: 1)
    expect{ render }.not_to raise_error
  end
end

describe 'campaigns/show.slim' do
  it 'renders without error' do
    assign :campaign, build(:campaign, id: 1)
    expect{ render }.not_to raise_error
  end
end

describe 'campaigns/index.slim' do
  it 'renders no campaigns without error' do
    assign :campaign, Campaign.none
    expect{ render }.not_to raise_error
  end

  it 'renders multiple campaigns without error' do
    3.times { create :campaign }
    assign :campaign, Campaign.all
    expect{ render }.not_to raise_error
  end

  it 'renders a single campaign without error' do
    create :campaign
    assign :campaign, Campaign.all
    expect{ render }.not_to raise_error
  end
end
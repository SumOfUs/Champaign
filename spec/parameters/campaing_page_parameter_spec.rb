require 'rails_helper'
require 'spec_helper'

RSpec.describe CampaignPageParameters do
  it 'should filter a tag list full of strings' do
    tag_list = ["1", "2", "3"]
    filter = CampaignPageParameters.new foo: :bar
    expect(filter.convert_tags(tag_list)).to eq([1, 2, 3])
  end

  it 'should filter out an empty string' do
    tag_list = ["1", "2", "3", ""]
    filter = CampaignPageParameters.new foo: :bar
    expect(filter.convert_tags(tag_list)).to eq([1, 2, 3])
  end

  it 'should handle an array of integers fine' do
    tag_list = [1, 2, 3, 4]
    filter = CampaignPageParameters.new foo: :bar
    expect(filter.convert_tags(tag_list)).to eq([1, 2, 3, 4])
  end
end

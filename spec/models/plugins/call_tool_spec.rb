# frozen_string_literal: true

# == Schema Information
#
# Table name: plugins_call_tools
#
#  id                            :integer          not null, primary key
#  page_id                       :integer
#  active                        :boolean
#  ref                           :string
#  created_at                    :datetime
#  updated_at                    :datetime
#  title                         :string
#  targets                       :json             is an Array
#  sound_clip_file_name          :string
#  sound_clip_content_type       :string
#  sound_clip_file_size          :integer
#  sound_clip_updated_at         :datetime
#  description                   :text
#  menu_sound_clip_file_name     :string
#  menu_sound_clip_content_type  :string
#  menu_sound_clip_file_size     :integer
#  menu_sound_clip_updated_at    :datetime
#  restricted_country_code       :string
#  caller_phone_number_id        :integer
#

require 'rails_helper'

describe Plugins::CallTool do
  let(:target_hashes) do
    [{ 'name' => 'Richard Roth', 'title' => 'Senator', 'phone_number' => '19166514031',
       'phone_extension' => nil, 'country_name' => 'United States of America', 'country_code' => 'US',
       'caller_id' => nil, 'fields' => { 'state' => 'California', 'other' => nil } },
     { 'name' => 'Tony Mendoza', 'title' => 'Senator', 'phone_number' => '19166514032',
       'phone_extension' => nil, 'country_name' => 'United States of America', 'country_code' => 'US',
       'caller_id' => nil, 'fields' => { 'state' => 'California', 'other' => nil } }]
  end

  describe '#sound_clip' do
    let(:sound_file) { File.new(Rails.root.join('spec', 'fixtures', 'sound.mp3')) }

    subject { Plugins::CallTool.create!(sound_clip: sound_file) }

    it 'attaches audio file' do
      subject = Plugins::CallTool.create!(sound_clip: sound_file)
      expect(subject.sound_clip).to be_present
      expect(subject.sound_clip.url).to match('sound.mp3')
    end

    it 'allows nil' do
      subject = Plugins::CallTool.create!
      expect(subject.sound_clip.present?).not_to be_present
    end
  end

  describe 'country_phone_codes' do
    let(:call_tool) { build(:call_tool) }

    it 'returns a list of phone codes' do
      list = call_tool.liquid_data[:countries_phone_codes]
      expect(list).to include(name: 'Argentina', code: '54')
      expect(list).to include(name: 'United States', code: '1')
    end

    it 'should return US in first place' do
      list = call_tool.liquid_data[:countries_phone_codes]
      expect(list.first[:name]).to eql('United States')
    end
  end

  describe '#restricted_country_code=' do
    it 'nullifies value when trying to set an empty string' do
      call_tool = build(:call_tool, restricted_country_code: 'AR')
      call_tool.restricted_country_code = ''
      expect(call_tool.restricted_country_code).to be_nil
    end
  end

  describe 'restricted_country_code validation' do
    it "doesn't allow invalid country codes" do
      call_tool = build(:call_tool, restricted_country_code: 'wrong')
      expect(call_tool).to be_invalid
      expect(call_tool.errors[:restricted_country_code]).to be_present
    end

    it 'allows valid country codes' do
      call_tool = build(:call_tool, restricted_country_code: 'AR')
      expect(call_tool).to be_valid
    end
  end

  describe '#target_filterable_fields' do
    it 'returns an array of strings' do
      keys = build(:call_tool).target_filterable_fields
      expect(keys).to be_an(Array)
      expect(keys.map(&:class).uniq).to eq [String]
    end

    it 'returns the correct keys' do
      keys = build(:call_tool, targets: target_hashes).target_filterable_fields
      expect(keys).to eq %w[name title country_name state]
    end
  end

  describe '#targets' do
    it 'instantiates a Target for each hash in the json array' do
      call_tool = build(:call_tool, targets: target_hashes)
      expect(call_tool.targets.map(&:class)).to eq [::CallTool::Target, ::CallTool::Target]
    end
  end

  describe '#target_by_attributes (dynamic targetting)' do
    it 'is an empty array by default' do
      call_tool = build(:call_tool)
      expect(call_tool.target_by_attributes).to be_an(Array)
      expect(call_tool.target_by_attributes.size).to be(0)
    end

    it 'can contain a list of columns' do
      call_tool = build(:call_tool, target_by_attributes: ['country_name'])
      expect(call_tool.target_by_attributes).to include('country_name')
      expect(call_tool.target_by_attributes.size).to be(1)
    end
  end
end

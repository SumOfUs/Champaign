# frozen_string_literal: true

# == Schema Information
#
# Table name: plugins_call_tools
#
#  id                           :integer          not null, primary key
#  active                       :boolean
#  description                  :text
#  menu_sound_clip_content_type :string
#  menu_sound_clip_file_name    :string
#  menu_sound_clip_file_size    :bigint(8)
#  menu_sound_clip_updated_at   :datetime
#  ref                          :string
#  restricted_country_code      :string
#  sound_clip_content_type      :string
#  sound_clip_file_name         :string
#  sound_clip_file_size         :bigint(8)
#  sound_clip_updated_at        :datetime
#  target_by_attributes         :string           default([]), is an Array
#  targets                      :json             is an Array
#  title                        :string
#  created_at                   :datetime
#  updated_at                   :datetime
#  caller_phone_number_id       :integer
#  page_id                      :integer
#

require 'rails_helper'

describe Plugins::CallTool do
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

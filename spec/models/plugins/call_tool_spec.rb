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
#  target_by_country             :boolean          default(TRUE)
#  menu_sound_clip_file_name     :string
#  menu_sound_clip_content_type  :string
#  menu_sound_clip_file_size     :integer
#  menu_sound_clip_updated_at    :datetime
#  restricted_country_code       :string
#  allow_manual_target_selection :boolean          default(FALSE)
#  caller_phone_number_id        :integer
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

  describe 'targets validations' do
    context 'given target_by_country is set' do
      let(:targets) { [build(:call_tool_target, :with_country), build(:call_tool_target)] }
      let(:call_tool) { build(:call_tool, targets: targets) }

      it 'requires the targets country to be set' do
        expect(call_tool).not_to be_valid
        expect(call_tool.errors[:targets]).to be_present
        expect(call_tool.errors[:targets]).to include("Country can't be blank (row 1)")
      end
    end

    context 'given target_by_country is not set' do
      let(:targets) { [build(:call_tool_target, :with_country), build(:call_tool_target)] }
      let(:call_tool) { build(:call_tool, targets: targets, target_by_country: false) }
      it 'allows targets with blank countries' do
        expect(call_tool).to be_valid
      end
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
end

# frozen_string_literal: true
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
end

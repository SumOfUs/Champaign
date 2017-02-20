# frozen_string_literal: true
# == Schema Information
#
# Table name: plugins_call_tools
#
#  id                      :integer          not null, primary key
#  page_id                 :integer
#  active                  :boolean
#  ref                     :string
#  created_at              :datetime
#  updated_at              :datetime
#  title                   :string
#  targets                 :json             is an Array
#  sound_clip_file_name    :string
#  sound_clip_content_type :string
#  sound_clip_file_size    :integer
#  sound_clip_updated_at   :datetime
#  description             :text
#  target_by_country       :boolean          default(TRUE)
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
end

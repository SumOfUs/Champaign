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
end

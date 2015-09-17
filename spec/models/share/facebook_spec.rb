require 'rails_helper'

describe Share::Facebook do
  describe 'validation' do
    subject { build(:share_facebook) }

    it 'is valid' do
      expect(subject).to be_valid
    end

    it 'description must be present' do
      subject.description = nil
      expect(subject).to_not be_valid
    end

    it 'title must be present' do
      subject.title = nil
      expect(subject).to_not be_valid
    end
  end
end



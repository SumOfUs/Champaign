require 'rails_helper'

describe Share::Email do
  describe 'validation' do
    subject { build(:share_email) }

    it 'is valid' do
      expect(subject).to be_valid
    end

    it 'subject must be present' do
      subject.subject = nil
      expect(subject).to_not be_valid
    end

    it 'body must be present' do
      subject.body = nil
      expect(subject).to_not be_valid
    end

    it 'body must contain {LINK}' do
      subject.body = "Foo"
      expect(subject).to_not be_valid
    end
  end
end


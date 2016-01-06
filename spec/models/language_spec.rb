require 'rails_helper'

describe Language do
  describe 'validations' do
    subject { Language.new(code: 'EN', name: 'English') }

    it 'is valid' do
      expect(subject).to be_valid
    end

    it "does not allow a nil code" do
      subject.code = nil
      expect(subject).to_not be_valid
    end

    it "does not allow a nil name" do
      subject.name = nil
      expect(subject).to_not be_valid
    end

    it "does not allow a blank code" do
      subject.code = ' '
      expect(subject).to_not be_valid
    end

    it "does not allow a blank name" do
      subject.name = ' '
      expect(subject).to_not be_valid
    end
  end
end

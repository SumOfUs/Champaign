require 'rails_helper'

describe Language do
  describe 'validations' do
    subject { Language.new(code: 'EN', name: 'English') }

    it 'is valid' do
      expect(subject).to be_valid
    end

    it "requires a code" do
      subject.code = ''
      expect(subject).to_not be_valid
    end

    it "requires a name" do
      subject.name = ''
      expect(subject).to_not be_valid
    end
  end
end

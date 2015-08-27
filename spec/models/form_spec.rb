require 'rails_helper'

describe Form do
  describe '.masters' do
    before do
      create(:form, master: false)
      create(:form, master: true)
    end

    it 'returns only masters' do
      expect(Form.masters.map(&:master?)).to eq([true])
    end
  end

  describe '#master' do
    it 'can be a master' do
      form = create(:form, master: true)
      expect(form.master?).to be true
    end
  end

  describe 'validations' do
    it "requires a title" do
      expect(Form.new).to_not be_valid
    end
  end
end

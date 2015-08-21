require 'rails_helper'

describe Form do
  describe 'validations' do
    it "requires a title" do
      expect(Form.new).to_not be_valid
    end
  end
end

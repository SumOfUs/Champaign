require 'rails_helper'

describe LiquidPartial do
  
  let(:partial) { create(:liquid_partial) }

  it "is valid" do
    expect(partial).to be_valid
  end

  describe "is invalid" do

    after :each do
      expect(partial).to be_invalid
    end

    it "with a blank title" do
      partial.title = " "
    end

    it "with a blank content" do
      partial.content = " "
    end
  end

end

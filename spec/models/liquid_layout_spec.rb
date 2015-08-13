require 'rails_helper'

describe LiquidLayout do
  
  let(:layout) { create(:liquid_layout) }

  it "is valid" do
    expect(layout).to be_valid
  end

  describe "is invalid" do

    after :each do
      expect(layout).to be_invalid
    end

    it "with a blank title" do
      layout.title = " "
    end

    it "with a blank content" do
      layout.content = " "
    end
  end

end

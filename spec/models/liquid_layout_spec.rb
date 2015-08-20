require 'rails_helper'

describe LiquidLayout do
  
  let(:layout) { create(:liquid_layout) }

  describe "is valid" do

    after :each do
      expect(layout).to be_valid
    end

    it "with factory settings" do
    end

    it "with a reference to a partial that does exist" do
      create :liquid_partial, title: 'existent'
      layout.content = "<div>{% include 'existent' %}</div>"
    end
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

    it "with a reference to a partial that doesn't exist" do
      layout.content = "<div>{% include 'nonexistent' %}</div>"
    end

  end

end

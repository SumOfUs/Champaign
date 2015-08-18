require 'rails_helper'

describe LiquidPartial do
  
  let(:partial) { create(:liquid_partial) }

  describe "is valid" do

    after :each do
      expect(partial).to be_valid
    end

    it "with factory settings" do
    end

    it "with multiple references to the same plugin" do
      partial.content = "<div>{{ plugins.actions[ref].text }}</div>
                         <div>{{ plugins.actions[ref].wink }}</div>"
    end
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

    it "with multiple references to different plugins" do
      partial.content = "<div>{{ plugins.actions[ref].text }}</div>
                         <div>{{ plugins.thermometer[ref].wink }}</div>"
    end
  end

end

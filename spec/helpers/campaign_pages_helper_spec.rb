require 'rails_helper'

describe CampaignPagesHelper do
  describe "#campaign_page_nav_item" do
    it "returns li element with link" do
      actual = helper.campaign_page_nav_item('foo', '/bar')
      expect(actual).to eq("<li><a href=\"/bar\">foo</a></li>")
    end
  end

  describe "#toggle_switch" do
    it "returns link when active" do
      actual = helper.toggle_switch(true, true, 'foo')
      expect(actual).to eq(
        "<a class=\"btn-primary btn toggle-button btn-default\">foo</a>"
      )
    end

    it "returns link when inactive" do
      actual = helper.toggle_switch(true, false, 'foo')
      expect(actual).to eq(
        "<a class=\" btn toggle-button btn-default\">foo</a>"
      )
    end
  end
end

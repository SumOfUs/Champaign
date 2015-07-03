require 'rails_helper'

RSpec.describe Widget, type: :model do

  let(:widget) { Widget.new(page_display_order: 1, type: "TextWidget", content: { body_html: "yippee!"}) }

  subject { widget }

  it { should be_valid }
  it { should respond_to :page_display_order }
  it { should respond_to :content }
  it { should respond_to :campaign_page_id }
  it { should respond_to :type }


  describe :type do
    it "should be invalid when not in the allowed types" do
      widget.type = "NotARealWidget"
      expect(widget).not_to be_valid
    end
  end

  describe :page_display_order do
    it "should be invalid when negative" do
      widget.page_display_order = -1
      expect(widget).not_to be_valid
    end

    it "should be invalid when fractional" do
      widget.page_display_order = 1.3
      expect(widget).not_to be_valid
    end

    it "should be invalid when zero" do
      widget.page_display_order = 0
      expect(widget).not_to be_valid
    end

    it "should be invalid when nil" do
      widget.page_display_order = nil
      expect(widget).not_to be_valid
    end

    it "should be valid when large" do
      widget.page_display_order = 9_999_999
      expect(widget).to be_valid
    end
  end

end

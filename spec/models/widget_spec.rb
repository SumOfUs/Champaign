describe Widget do

  let(:widget) { Widget.new(page_display_order: 1, type: "TextBodyWidget", content: { text_body_html: "yippee!"}) }

  subject { widget }

  it { should be_valid }
  it { should respond_to :page_display_order }
  it { should respond_to :content }
  it { should respond_to :page_id }
  it { should respond_to :page }
  it { should respond_to :type }
  it { should respond_to :page_type }

  describe 'page' do

    let(:english) { create :language }
    let(:template) { create :template }
    let(:campaign_page) { create :campaign_page, language: english }

    it "should be able to assign a template as page" do
      widget.page = template
      widget.save!
      expect(template.reload.widgets.first).to eq widget
    end

    it "should be able to assign a campaign_page as page" do
      widget.page = campaign_page
      widget.save!
      expect(campaign_page.reload.widgets.first).to eq widget
    end

  end

  describe 'type' do
    it "should be invalid when not in the allowed types" do
      widget.type = "NotARealWidget"
      expect(widget).not_to be_valid
    end
  end

  describe 'page_display_order' do
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

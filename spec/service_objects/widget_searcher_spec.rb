require 'rspec'

describe 'Full Text Search' do
  let(:widget_searcher) { WidgetSearcher.new }
  let(:test_text) { 'A testing string' }
  let(:false_text)
  let(:widget) { TextBodyWidget.new text_body_html: test_text }
  let(:page) { CampaignPage.new widgets: [widget] }

  it 'should search the text of a widget and return the found page' do
    created_page = page.save
    expect(widget_searcher.search(test_text)).to eq([created_page])
  end

  it 'should not return a page if no text is found' do
    page.save
    expect(widget_searcher.search('fake string')).to eq([])
  end
end

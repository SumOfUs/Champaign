require 'rails_helper'

describe 'Full Text Search' do
  let(:test_text) { 'A testing string' }
  let(:widget) { TextBodyWidget.create! text_body_html: test_text, page_display_order: 1 }
  let(:language) { Language.create! language_name: 'test_language', language_code: 'tl' }
  let(:params) { {:title => 'test page', :search => test_text } }
  let(:widget_searcher) { WidgetSearcher.new(params) }
  let(:page) {
    CampaignPage.create! widgets: [widget], title: 'A test page title',
                         slug: 'a-slug', active: true, featured: false,
                         language: language
  }
  let(:tag_name) { 'A testing tag' }
  let(:tag_url) { '/foo/bar' }
  let(:tag) { Tag.create! tag_name: tag_name, actionkit_uri: tag_url }

  it 'should search the text of a widget and return the found page' do
    expect(widget_searcher.search(page_text: test_text)).to eq([page])
  end

  it 'should not return a page if no text is found' do
    expect(widget_searcher.search(page_text: 'fake string')).to eq([])
  end

  it 'should be able to search for a page based on the tags on that page' do
    page.tags = [tag]
    expect(widget_searcher.tag_search(tag_name: tag_name)).to eq([page])
  end

  it 'should return an empty array when searching for a page without the expected tags' do
    page.tags = [tag]
    expect(widget_searcher.tag_search(tag_name: 'a bad tag name')).to eq([])
  end
end

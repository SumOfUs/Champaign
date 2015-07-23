require 'rails_helper'

describe 'Full Text Search' do
  let(:test_text) { 'A testing string' }
  let(:widget) { TextBodyWidget.create! text_body_html: test_text, page_display_order: 1 }
  let(:language) { Language.create! language_name: 'test_language', language_code: 'tl' }
  let(:params) { {:title => 'test page', :search => [content_search: test_text] } }
  let(:page) {
    CampaignPage.create! widgets: [widget], title: 'A test page title',
                         slug: 'a-slug', active: true, featured: false,
                         language: language
  }
  let(:widget_searcher) { WidgetSearcher.new(params) }
  let(:failed_widget_searcher) { WidgetSearcher.new({:title => 'test page 2', :search => 'this string will not exist' })}
  let(:tag_name) { 'A testing tag' }
  let(:tag_url) { '/foo/bar' }
  let(:tag) { Tag.create! tag_name: tag_name, actionkit_uri: tag_url }

  it 'prettyprints widget' do
    pp 'widget', page.widgets
    pp 'all widgets', TextBodyWidget.all
    pp 'pages widgets', page.widgets
  end

  it 'should search the text of a widget and return the found page' do
    # expect(widget_searcher.search).to eq(page)
    expect(widget_searcher.get_matches_by_text_widget(test_text)).to eq(page)
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

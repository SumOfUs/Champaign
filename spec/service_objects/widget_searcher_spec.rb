require 'rails_helper'

describe 'Page search' do

  let!(:page) {
    create(:page,
           title: 'test page',
           widgets: [create(:text_body_widget, text_body_html: test_text)],
           language: build(:language))
  }
  let(:params) { {:search => {content_search: test_text} } }
  let(:widget_searcher) { WidgetSearcher.new(params) }
  let(:test_text) { 'test' }

  context 'search by text content' do
    it 'searches with params and returns the matching page' do
      expect(widget_searcher.search).to eq([page])
    end
    it 'searches the text of a widget and returns the found page' do
      expect(widget_searcher.get_matches_by_text_widget(test_text)).to eq([page])
    end
  end

  context 'search by tag' do
    let(:tag_name) { 'A testing tag' }
    let(:tag) { build(:tag, tag_name: 'A testing tag', actionkit_uri: '/foo/bar') }

    it 'searches for a page based on the tags on that page' do
      page.tags = [tag]
      expect(widget_searcher.tag_search(tag_name: tag_name)).to eq([page])
    end
    it 'returns an empty collection when no page with the existing tags exists' do
      page.tags = [tag]
      expect(widget_searcher.tag_search(tag_name: 'a bad tag name')).to eq([])
    end
  end

end

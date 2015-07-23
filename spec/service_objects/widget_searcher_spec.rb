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

  context 'Full Text Search' do
    it 'should search with params and return the found page' do
      expect(widget_searcher.search).to eq([page])
    end
    it 'should search the text of a widget and return the found page' do
      expect(widget_searcher.get_matches_by_text_widget(test_text)).to eq([page])
    end
  end

  context 'Tag search' do
    let(:tag_name) { 'A testing tag' }
    let(:tag) { build(:tag, tag_name: 'A testing tag', actionkit_uri: '/foo/bar') }

    it 'should be able to search for a page based on the tags on that page' do
      page.tags = [tag]
      expect(widget_searcher.tag_search(tag_name: tag_name)).to eq([page])
    end
    it 'should return an empty array when searching for a page without the expected tags' do
      page.tags = [tag]
      expect(widget_searcher.tag_search(tag_name: 'a bad tag name')).to eq([])
    end
  end
  
end

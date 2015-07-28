require 'rails_helper'

describe 'Search ::' do

  #TODO TOMORROW: I think :params are not specified correctly, and when calling page_searcher.search,
  #the switch doesn't work properly because it fails to match against the params hash.

  let(:test_text) { 'a spectacular test string' }
  let(:language) { build(:language) }
  let!(:matching_widget) { create(:text_body_widget, text_body_html: test_text) }
  let!(:nonmatching_widget) { create(:text_body_widget, text_body_html: 'a non-matching text body') }
  let!(:tag) { create(:tag, tag_name: test_text, actionkit_uri: '/foo/bar') }
  let!(:campaign) { create(:campaign, campaign_name: test_text) }
  let!(:petition_widget) {create :petition_widget}

  describe 'PageSearcher' do

    let!(:body_match_page) {
      create(:page,
             title: 'a non-matching title',
             widgets: [matching_widget],
             language: build(:language, language_code: 'SWE', language_name: 'Swedish'),
             tags: [tag])
    }
    let!(:title_match_page) {
      create(:page,
             title: test_text + ' title!',
             widgets: [nonmatching_widget],
             language: language,
             campaign: campaign)
    }
    let!(:petition_page) {
      create(:page,
             title: 'not a match for anything',
             widgets: [petition_widget],
             language: build(:language, language_code: 'FIN', language_name: 'Finnish'),
             campaign: create(:campaign, campaign_name: 'herpaderpa campaign')
      )
    }

    subject { Search::PageSearcher }

    describe '._search' do
      it 'finds' do
        expect(subject._search('test')).to match_array([title_match_page, body_match_page])
      end
    end

    context 'search by text content' do
      let(:text_searcher) { Search::PageSearcher.new({search: {content_search: test_text} }) }
      it 'gets pages that match by title or by text body if the text search method is called' do
        expect(text_searcher.search).to match_array([title_match_page, body_match_page])
      end
    end

    context 'search by tag' do
      let(:tag_searcher) { Search::PageSearcher.new({search: {tags: [tag.id]} }) }
      it 'searches for a page based on the tags on that page' do
        expect(tag_searcher.search).to eq([body_match_page])
      end
    end

    context 'search by campaign' do
      let(:search_by_campaign) { Search::PageSearcher.new({search: {campaign: [campaign.id]} }) }
      it 'searches for a page based on the campaign it belongs to' do
        expect(search_by_campaign.search).to eq([title_match_page])
      end
    end

    context 'search by language' do
      let(:language_searcher) { Search::PageSearcher.new({search: {language: [language.id]} }) }
      it 'finds only the page that corresponds to the specified language' do
        expect(language_searcher.search).to eq([title_match_page])
      end
    end

    context 'search by widget' do
      let(:search_by_widget) { Search::PageSearcher.new({search: {widget_type: ['PetitionWidget']} }) }
      it 'finds the page that corresponds to the desired widget type' do
        expect(search_by_widget.search).to eq([petition_page])
      end
    end

    context 'search by multiple criteria' do

      let!(:multi_match_page) {
        create(:page,
               title: 'multimatch page',
               widgets: [matching_widget, petition_widget],
               language: language,
               campaign: campaign,
               tags: [tag])
      }
      let(:new_params) {
        { search: {
            content_search: test_text,
            tags: [tag.id],
            widget_type: ['PetitionWidget'],
            language: language.id
          }
        }
      }
      let(:new_page_searcher) { Search::PageSearcher.new(new_params) }
      it 'finds a page that matches the search query by tags, language, widget type and text content' do
        expect(new_page_searcher.search).to match_array([multi_match_page])
      end
    end

  end

  describe 'WidgetSearcher' do

    it 'finds the matching widget based on the search text' do
      expect(Search::WidgetSearcher.text_widget_search(test_text)).to eq([matching_widget])
    end

    it 'finds widgets that match the specified widget type' do
      expect(Search::WidgetSearcher.widget_type_search(['PetitionWidget'])).to match_array(
                [petition_widget])
    end

  end

end

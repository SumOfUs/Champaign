require 'rails_helper'

describe 'Search ::' do

  let(:test_text) { 'a spectacular test string' }
  let(:language) { build(:language) }
  let!(:tag) { create(:tag, tag_name: test_text, actionkit_uri: '/foo/bar') }
  let!(:campaign) { create(:campaign, campaign_name: test_text) }

  describe 'PageSearcher' do

    let!(:content_tag_match) {
      create(:page,
             title: 'a non-matching title',
             language: build(:language, language_code: 'SWE', language_name: 'Swedish'),
             tags: [tag],
             content: test_text
      )
    }
    let!(:title_language_campaign_match) {
      create(:page,
             title: test_text + ' title!',
             language: language,
             campaign: campaign)
    }

    context 'search by text content' do
      let(:text_searcher) { Search::PageSearcher.new({search: {content_search: test_text} }) }
      it 'gets pages that match by title or by text body if the text search method is called' do
        expect(text_searcher.search).to match_array([content_tag_match, title_language_campaign_match])
      end
    end

    context 'search by tag' do
      let(:tag_searcher) { Search::PageSearcher.new({search: {tags: [tag.id]} }) }
      it 'searches for a page based on the tags on that page' do
        expect(tag_searcher.search).to eq([content_tag_match])
      end
    end

    context 'search by campaign' do
      let(:search_by_campaign) { Search::PageSearcher.new({search: {campaign: [campaign.id]} }) }
      it 'searches for a page based on the campaign it belongs to' do
        expect(search_by_campaign.search).to eq([title_language_campaign_match])
      end
    end

    context 'search by language' do
      let(:language_searcher) { Search::PageSearcher.new({search: {language: [language.id]} }) }
      it 'finds only the page that corresponds to the specified language' do
        expect(language_searcher.search).to eq([title_language_campaign_match])
      end
    end

    context 'search by plugin' do
      xit 'finds the page that is associated with that plugin type' do

      end
    end

    context 'search by multiple criteria' do

      let!(:multi_match_page) {
        create(:page,
               title: 'multimatch page',
               language: language,
               campaign: campaign,
               tags: [tag])
      }
      let(:multi_match_params) {
        { search: {
            content_search: 'multimatch page',
            tags: [tag.id],
            language: language.id
          }
        }
      }
      let(:new_page_searcher) { Search::PageSearcher.new(multi_match_params) }
      it 'finds a page that matches the search query by tags, language and text content' do
        expect(new_page_searcher.search).to match_array([multi_match_page])
      end
    end

  end

end

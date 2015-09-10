require 'rails_helper'

describe 'Search ::' do

  let(:test_text) { 'a spectacular test string' }
  let(:language) { build(:language) }
  let!(:tag) { create(:tag, tag_name: test_text, actionkit_uri: '/foo/bar') }
  let!(:campaign) { create(:campaign, campaign_name: test_text) }
  let!(:campaign2) { create(:campaign, campaign_name: 'Why not Zoidberg?') }
  let!(:layout) { create(:liquid_layout) }

  describe 'PageSearcher' do

    let!(:content_tag_plugin_layout_match) {
      create(:page,
             title: 'a non-matching title',
             language: build(:language, code: 'SWE', name: 'Swedish'),
             tags: [tag],
             content: test_text,
             liquid_layout: layout,
             campaign: campaign2
      )
    }
    let!(:title_language_campaign_match) {
      create(:page,
             title: test_text + ' title!',
             language: language,
             campaign: campaign)
    }

    let!(:plugin) { create(:plugins_action, campaign_page: content_tag_plugin_layout_match, active:true)}

    context 'searches through a single criterion' do

      context 'search by text content' do
        let(:text_searcher) { Search::PageSearcher.new({search: {content_search: test_text} }) }
        it 'gets pages that match by title or by text body if the text search method is called' do
          expect(text_searcher.search).to match_array([content_tag_plugin_layout_match, title_language_campaign_match])
        end
      end

      context 'search by tag' do
        let(:tag_searcher) { Search::PageSearcher.new({search: {tags: [tag.id]} }) }
        it 'searches for a page based on the tags on that page' do
          expect(tag_searcher.search).to match_array([content_tag_plugin_layout_match])
        end
      end

      context 'search by campaign' do
        let(:search_by_campaign) { Search::PageSearcher.new({search: {campaign: [campaign.id]} }) }
        it 'searches for a page based on the campaign it belongs to' do
          expect(search_by_campaign.search).to match_array([title_language_campaign_match])
        end
      end

      context 'search by layout' do
        let(:layout_searcher) { Search::PageSearcher.new({search: {layout: [layout.id]} }) }
        it 'finds a page that contains the specified liquid layout' do
          expect(layout_searcher.search).to match_array([content_tag_plugin_layout_match])
        end
      end

      context 'search by language' do
        let(:language_searcher) { Search::PageSearcher.new({search: {language: [language.id]} }) }
        it 'finds only the page that corresponds to the specified language' do
          expect(language_searcher.search).to match_array([title_language_campaign_match])
        end
      end

      context 'search by plugin' do
        let(:plugin_searcher) { Search::PageSearcher.new({search: {plugin_type: ['Plugins::Action']}})}
        it 'finds the page that is associated with that plugin type' do
          expect(plugin_searcher.search).to match_array([content_tag_plugin_layout_match])
        end
      end
    end

    context 'searches by multiple criteria' do

      let!(:matches_by_content_language_campaign_tags_layout) {
        create(:page,
               title: 'multimatch page',
               language: language,
               campaign: campaign,
               tags: [tag],
               liquid_layout: layout)
      }

      let!(:matches_by_content_language_campaign) {
        create(:page,
               title: 'multimatch page 1',
               language: language,
               campaign: campaign,
               tags: [create(:tag, tag_name: 'ninja tag', actionkit_uri: '/foo/bar2')],
               liquid_layout: create(:liquid_layout))
      }

      let!(:matches_by_content_language_tags_layout) {
        create(:page,
               title: 'multimatch page 2',
               language: language,
               campaign: campaign2,
               tags: [tag],
               liquid_layout: layout)
      }

      let(:content_tag_language_params) {
        { search: {
            content_search: 'multimatch',
            tags: [tag.id],
            language: language.id
          }
        }
      }

      let(:content_language_campaign_tags_params) {
        { search: {
            content_search: 'multimatch',
            language: language.id,
            campaign: campaign,
            tags: [tag.id]
          }
        }
      }

      let(:layout_tags_searcher_params) {
        { search: {
            tags: [tag.id],
            layout: layout
          }
        }
      }


      let(:content_language_campaign_tags_searcher) { Search::PageSearcher.new(content_language_campaign_tags_params) }
      let(:content_tag_language_searcher) { Search::PageSearcher.new(content_tag_language_params) }
      let(:layout_searcher) { Search::PageSearcher.new({search: {layout: [create(:liquid_layout, title:'tricky layout')]} }) }
      let(:layout_tags_searcher) { Search::PageSearcher.new(layout_tags_searcher_params) }


      it 'finds a page that matches the search query by tags, language and text content' do
        expect(content_tag_language_searcher.search).to match_array([matches_by_content_language_campaign_tags_layout, matches_by_content_language_tags_layout])
      end

      it 'finds pages that match the search query by content, language, campaign and tags ' do
        expect(content_language_campaign_tags_searcher.search).to match_array([matches_by_content_language_campaign_tags_layout])
      end

      it 'does not find a match when the search parameters contain a liquid layout there is no match for' do
        expect(layout_searcher.search).to match_array([])
      end

      it 'finds pages when searching by matching tags and layout' do
        expect(layout_tags_searcher.search).to match_array([matches_by_content_language_campaign_tags_layout, matches_by_content_language_tags_layout, content_tag_plugin_layout_match])
      end

      context 'uses OR queries for categories where it makes sense (campaign, language) and not for other categories' do

        let(:finds_pages_for_all_campaigns) { Search::PageSearcher.new({ search: {campaign: [campaign.id, campaign2.id]} }) }
        let(:impossible_tag_searcher) { Search::PageSearcher.new({ search: {tags: Tag.all.pluck('id').push(Tag.last.id+1)} }) }
        let(:campaign_language_searcher) { Search::PageSearcher.new({ search: {language: language, campaign: Campaign.all.pluck('id')} }) }

        it 'finds all pages that match the specified array of campaigns' do
          expect(finds_pages_for_all_campaigns.search).to match_array([
            content_tag_plugin_layout_match,
            title_language_campaign_match,
            matches_by_content_language_campaign_tags_layout,
            matches_by_content_language_campaign,
            matches_by_content_language_tags_layout,
          ])
        end

        it 'finds no pages when a search is done with a combination of tags that exists for no page' do
          expect(impossible_tag_searcher.search).to match_array([])
        end

        it 'searches for pages that belong to any campaign of a particular language' do
          expect(campaign_language_searcher.search).to match_array([
            title_language_campaign_match,
            matches_by_content_language_campaign_tags_layout,
            matches_by_content_language_campaign,
            matches_by_content_language_tags_layout
           ])
        end

      end

    end

  end

end

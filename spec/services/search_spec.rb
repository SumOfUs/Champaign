require 'rails_helper'

describe 'Search ::' do

  let(:test_text) { 'a spectacular test string' }
  let!(:tag) { create(:tag, name: test_text, actionkit_uri: '/foo/bar') }
  let!(:alternative_tag) { create(:tag, name: 'alternative tag', actionkit_uri: '/alternative_tag/') }
  let!(:the_best_tag) { create(:tag, name: 'best tag ever', actionkit_uri: '/secretly_insecure/') }
  let!(:unused_tag) { create(:tag, name: 'such a lonely tag', actionkit_uri: '/foreveralone') }
  let!(:hipster_tag) { create(:tag, name: 'tag with moustache', actionkit_uri: '/coffee_with_that') }
  let!(:only_tag) { create(:tag, name: 'only tag on a page', actionkit_uri: '/entitled/tag') }
  let!(:tag1) { create(:tag, name: 'tag1', actionkit_uri: '/tag1') }
  let!(:tag2) { create(:tag, name: 'tag2', actionkit_uri: '/tag2') }
  let!(:tag3) { create(:tag, name: 'tag3', actionkit_uri: '/tag3') }
  let!(:tag4) { create(:tag, name: 'tag4', actionkit_uri: '/tag4') }
  let!(:tag5) { create(:tag, name: 'tag5', actionkit_uri: '/tag5') }
  let!(:tag6) { create(:tag, name: 'tag6', actionkit_uri: '/tag6') }
  let!(:unpopular_tag) { create(:tag, name: 'belongs to just one page', actionkit_uri: '/meh') }
  let!(:campaign) { create(:campaign, name: test_text) }
  let!(:campaign2) { create(:campaign, name: 'Why not Zoidberg?') }
  let!(:twin_campaign) { create(:campaign, name: 'Campaign that contains two pages') }
  let!(:unimpactful_campaign) { create(:campaign, name: 'Campaign with just one page?') }
  let!(:layout) { create(:liquid_layout) }
  let!(:unused_layout) { create(:liquid_layout, title: 'too bad for anyone to use, ever') }
  let!(:messy_layout) { create(:liquid_layout, title: 'has kinda tacky UX')}
  let!(:twin_layout) { create(:liquid_layout, title: 'Layout that has two pages associated with it')}
  let!(:language) { create(:language) }
  let!(:klingon) { create(:language, code: 'KLI', name: 'Klingon') }
  let!(:pig_latin) { create(:language, code: 'PIG', name: 'Oink_oink') }
  let!(:unused_language) { create(:language, code: 'NIL', name: 'Esperanto') }

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
             campaign: campaign,
             tags: [alternative_tag]
      )
    }

    let!(:single_return_page) {
      create(:page,
             title: 'a special snowflake',
             tags: [hipster_tag, unpopular_tag],
             language: pig_latin,
             campaign: unimpactful_campaign,
             liquid_layout: messy_layout
      )
    }


    let!(:twin_page_1) {
      create(:page,
             title: 'looks suspiciously like twin page 2',
             tags: [only_tag],
             language: klingon,
             campaign: twin_campaign,
             liquid_layout: twin_layout
      )
    }

    let!(:twin_page_2) {
      create(:page,
             title: 'looks suspiciously like twin page 1',
             tags: [only_tag],
             language: klingon,
             campaign: twin_campaign,
             liquid_layout: twin_layout
      )
    }

    let!(:page_that_doesnt_match_anything) {
      create(:page,
         title: 'Not a good match',
         language: build(:language, code: 'FIN', name: 'Finnish'),
         tags: [
             create(:tag, name: 'tag not found', actionkit_uri: '/foo/404'),
             create(:tag, name: 'tag erroror', actionkit_uri: '/foo/500')
         ],
         content: 'totally arbitrary content',
         campaign: create(:campaign, name: 'a not very impactful test campaign')
      )
    }

    let!(:plugin) { create(:plugins_action, campaign_page: content_tag_plugin_layout_match, active:true)}

    context 'validates search parameters' do
      describe 'returns all campaign pages when searching' do
        it 'with an empty array' do
          expect(Search::PageSearcher.new({search: [] }).search).to match_array(CampaignPage.all)
        end
        it 'with nil' do
          expect(Search::PageSearcher.new({search: nil }).search).to match_array(CampaignPage.all)
        end
        it 'with a non-existent search type' do
          expect(Search::PageSearcher.new({search: {inject_some_sql: "MaliciousCampaign');DROP TABLE Campaigns;--"} }).search).to match_array(CampaignPage.all)
        end
        it 'with an empty string' do
          expect(Search::PageSearcher.new({search: '' }).search).to match_array(CampaignPage.all)
        end
        it 'with no search parameters' do
          expect(Search::PageSearcher.new({}).search).to match_array(CampaignPage.all)
        end
      end
    end

    context 'searches through a single criterion' do

      context 'search by text content' do
        let(:text_searcher) { Search::PageSearcher.new({search: {content_search: test_text} }) }
        it 'gets pages that match by title or by text body if the text search method is called' do
          expect(text_searcher.search).to match_array([content_tag_plugin_layout_match, title_language_campaign_match])
        end
      end

      context 'search by tag' do
        let!(:has_many_tags) {
          create(:page,
                 title: 'a very taggy page',
                 tags: [alternative_tag, the_best_tag],
          )
        }
        let!(:intersection_page_1) {
          create(:page,
                 title: 'has one same tag as intersection page 2',
                 tags: [tag1, tag2, tag3, tag4],
          )
        }

        let!(:intersection_page_2) {
          create(:page,
                 title: 'has one same tag as intersection page 1',
                 tags: [tag3, tag4, tag5],
          )
        }
        let(:tag_searcher) { Search::PageSearcher.new({search: {tags: [tag.id]} }) }
        it 'searches for a page based on the tags on that page' do
          expect(tag_searcher.search).to match_array([content_tag_plugin_layout_match])
        end

        describe 'does not filter by tag when searching' do
          it 'with an empty tag array' do
            expect((Search::PageSearcher.new({search: {tags: []}})).search).to match_array(CampaignPage.all)
          end
          it 'with tag array set to nil' do
            expect((Search::PageSearcher.new({search: {tags: nil}})).search).to match_array(CampaignPage.all)
          end
          it 'with an empty string' do
            expect((Search::PageSearcher.new({search: {tags: ''}})).search).to match_array(CampaignPage.all)
          end
        end
        describe 'does not return any pages when searching' do
          it 'with a non-existent tag id' do
            expect((Search::PageSearcher.new({search: {tags: [Tag.last.id+1]}})).search).to match_array([])
          end
          it 'with an unused tag' do
            expect((Search::PageSearcher.new({search: {tags: [unused_tag.id]}})).search).to match_array([])
          end
          it 'with a used tag and an unused tag' do
            expect((Search::PageSearcher.new({search: {tags: [unused_tag.id, tag.id]}})).search).to match_array([])
          end

          it 'with two used tags never used on the same page' do
            expect((Search::PageSearcher.new({search: {tags: [tag.id, alternative_tag.id]}})).search).to match_array([])
          end
        end

        describe 'returns one page when searching' do
          it "with a tag that's only assigned to that page" do
            expect((Search::PageSearcher.new({search: {tags: [tag.id]}})).search).to match_array([content_tag_plugin_layout_match])
          end
          it "with one of that page's several tags" do
            expect((Search::PageSearcher.new({search: {tags: [the_best_tag.id]}})).search).to match_array([has_many_tags])
          end
          it "with multiple of that page's tags in any order" do
            expect((Search::PageSearcher.new({search: {tags: [hipster_tag.id, unpopular_tag.id]}})).search).to match_array([single_return_page])
            expect((Search::PageSearcher.new({search: {tags: [unpopular_tag.id, hipster_tag.id]}})).search).to match_array([single_return_page])
          end
          it "with a tag that matches two pages and a tag that matches one page" do
            expect((Search::PageSearcher.new({search: {tags: [alternative_tag.id, the_best_tag.id]}})).search).to match_array([has_many_tags])
          end
        end

        describe 'returns multiple pages when searching' do
          it "with a tag as the only tag of both pages" do
            expect((Search::PageSearcher.new({search: {tags: [alternative_tag.id, the_best_tag.id]}})).search).to match_array([has_many_tags])
          end
          it "with a tag used as one of several on both pages" do
            expect((Search::PageSearcher.new({search: {tags: [tag3.id]}})).search).to match_array([intersection_page_1,intersection_page_2])
          end
          it "with multiple tags used as one of several on both pages" do
            expect((Search::PageSearcher.new({search: {tags: [tag3.id, tag4.id]}})).search).to match_array([intersection_page_1,intersection_page_2])
          end
        end

      end

      context 'search by campaign' do
        let(:search_by_campaign) { Search::PageSearcher.new({search: {campaign: [campaign.id]} }) }
        let!(:unused_campaign) { create(:campaign, name:'unused campaign') }
        it 'searches for a page based on the campaign it belongs to' do
          expect(search_by_campaign.search).to match_array([title_language_campaign_match])
        end

        describe 'returns all pages when searching' do
          it 'with an empty array' do
            expect(Search::PageSearcher.new({search: {campaign: []} }).search).to match_array(CampaignPage.all)
          end
          it 'with nil' do
            expect(Search::PageSearcher.new({search: {campaign: nil} }).search).to match_array(CampaignPage.all)
          end

          it 'with an empty string' do
            expect(Search::PageSearcher.new({search: {campaign: ''} }).search).to match_array(CampaignPage.all)
          end
        end

        describe 'returns no pages when searching' do
          it 'with a non-existent campaign id' do
            expect(Search::PageSearcher.new({search: {campaign: [CampaignPage.last.id+1]} }).search).to match_array([])
          end
          it 'with an unused campaign id' do
            expect(Search::PageSearcher.new({search: {campaign: [unused_campaign.id]} }).search).to match_array([])
          end
        end

        describe 'returns one page when searching' do
          it 'with a campaign that only contains one page' do
            expect(Search::PageSearcher.new({search: {campaign: [unimpactful_campaign.id]} }).search).to match_array([single_return_page])
          end
        end

        describe 'returns some pages when searching' do
          it 'with a used campaign id and an unused campaign id' do
            expect(Search::PageSearcher.new({search: {campaign: [unimpactful_campaign.id, unused_campaign.id]} }).search).to match_array([single_return_page])
          end
        end

        describe 'returns multiple pages when searching' do
          it 'with mutiple campaign ids that different pages belong to' do
            expect(Search::PageSearcher.new({search: {campaign: [unimpactful_campaign.id, twin_campaign.id]} }).search).to match_array([
              twin_page_1, twin_page_2, single_return_page
            ])
          end
          it 'with a campaign id that several pages belong to' do
            expect(Search::PageSearcher.new({search: {campaign: [twin_campaign.id]} }).search).to match_array([twin_page_1, twin_page_2])
          end
        end

      end

      context 'search by layout' do
        let(:layout_searcher) { Search::PageSearcher.new({search: {layout: [layout.id]} }) }

        it 'finds a page that contains the specified liquid layout' do
          expect(layout_searcher.search).to match_array([content_tag_plugin_layout_match])
        end

        describe 'returns all campaign pages unfiltered when searching' do
          describe 'returns all pages when searching' do
            it 'with an empty array' do
              expect(Search::PageSearcher.new({search: {layout: []} }).search).to match_array(CampaignPage.all)
            end
            it 'with nil' do
              expect(Search::PageSearcher.new({search: {layout: nil} }).search).to match_array(CampaignPage.all)
            end

            it 'with an empty string' do
              expect(Search::PageSearcher.new({search: {layout: ''} }).search).to match_array(CampaignPage.all)
            end
          end
        end

        describe 'returns no pages when searching' do
          it 'with a non-existent layout' do
            expect(Search::PageSearcher.new({search: {layout: [LiquidLayout.last.id+1]} }).search).to match_array([])
          end
          it 'with an unused layout' do
            expect(Search::PageSearcher.new({search: {layout: [unused_layout.id]} }).search).to match_array([])
          end
        end

        describe 'returns one page when searching' do
          it 'with a layout that only one page belongs to' do
            expect(Search::PageSearcher.new({search: {layout: [messy_layout.id]} }).search).to match_array([single_return_page])
          end
        end

        describe 'returns some pages when searching' do
          it 'with a used layout and an unused layout' do
            expect(Search::PageSearcher.new({search: {layout: [messy_layout.id, unused_layout.id]}}).search).to match_array([single_return_page])
          end
        end

        describe 'returns multiple pages when searching' do
          it 'with mutiple layouts that different pages belong to' do
            expect(Search::PageSearcher.new({search: {layout: [messy_layout.id, twin_layout.id]}}).search).to match_array([single_return_page, twin_page_1, twin_page_2])
          end
          it 'with a layout that several pages belong to' do
            expect(Search::PageSearcher.new({search: {layout: [twin_layout.id]}}).search).to match_array([twin_page_1, twin_page_2])
          end
        end

      end

      context 'search by language' do
        let(:language_searcher) { Search::PageSearcher.new({search: {language: [language.id]} }) }
        it 'finds only the page that corresponds to the specified language' do
          expect(language_searcher.search).to match_array([title_language_campaign_match])
        end
        describe 'returns all campaign pages unfiltered when searching' do
          describe 'returns all pages when searching' do
            it 'with an empty array' do
              expect(Search::PageSearcher.new({search: {language: []} }).search).to match_array(CampaignPage.all)
            end
            it 'with nil' do
              expect(Search::PageSearcher.new({search: {language: nil} }).search).to match_array(CampaignPage.all)
            end

            it 'with an empty string' do
              expect(Search::PageSearcher.new({search: {language: ''} }).search).to match_array(CampaignPage.all)
            end
          end
        end

        describe 'returns no pages when searching' do
          it 'with a non-existent language' do
            expect(Search::PageSearcher.new({search: {language: [Language.last.id+999]} }).search).to match_array([])
          end
          it 'with an unused language' do
            expect(Search::PageSearcher.new({search: {language: [unused_language.id]} }).search).to match_array([])
          end
        end

        describe 'returns one page when searching' do
          it 'with a language that only one page belongs to' do
            expect(Search::PageSearcher.new({search: {language: [pig_latin.id]} }).search).to match_array([single_return_page])
          end
        end

        describe 'returns some pages when searching' do
          it 'with a used language and an unused language' do
            expect(Search::PageSearcher.new({search: {language: [pig_latin.id, unused_language.id]}}).search).to match_array([single_return_page])
          end
        end

        describe 'returns multiple pages when searching' do
          it 'with mutiple languages that different pages belong to' do
            expect(Search::PageSearcher.new({search: {language: [pig_latin.id, klingon.id]}}).search).to match_array([single_return_page, twin_page_1, twin_page_2])
          end
          it 'with a language that several pages belong to' do
            expect(Search::PageSearcher.new({search: {language: [klingon.id]}}).search).to match_array([twin_page_1, twin_page_2])
          end
        end
      end

      context 'search by plugin' do
        let(:plugin_searcher) { Search::PageSearcher.new({search: {plugin_type: ['Plugins::Action']}})}
        it 'finds the page that is associated with that plugin type' do
          expect(plugin_searcher.search).to match_array([content_tag_plugin_layout_match])
        end
        describe 'returns all pages when searching' do
          it 'with an empty array' do
            expect(Search::PageSearcher.new({search: {plugin: []}}).search).to match_array(CampaignPage.all)
          end
          it 'with nil' do
            expect(Search::PageSearcher.new({search: {plugin: nil}}).search).to match_array(CampaignPage.all)
          end
          it 'with empty string' do
            expect(Search::PageSearcher.new({search: {plugin: ""}}).search).to match_array(CampaignPage.all)
          end
        end
        describe 'returns no pages when searching' do
          it 'if searching with a layout that does not contain the plugin' do

          end
          it 'if searching with a layout that does contain the plugin but if all of the matching pages have that plugin turned off'
          it 'if searching with a plugin that does not exist'
          it 'if searching with several plugins where a page matches one but not the rest of them'
          it 'if searching with several plugins where a page matches by criteria but the requested plugins are deactivated'
        end
        describe 'returns some pages when searching' do
          it 'finds a page that belongs to a layout that contains the plugin and the plugin is activated'
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
               tags: [create(:tag, name: 'ninja tag', actionkit_uri: '/foo/bar2')],
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

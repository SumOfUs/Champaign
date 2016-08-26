# frozen_string_literal: true
require 'rails_helper'
require_relative '../../page_searcher/multiple_criterion_search/multiple_search_data.rb'
require_relative '../page_searcher_spec_data.rb'

describe 'Search ::' do
  describe 'PageSearcher' do
    context 'searches by multiple criteria' do
      include_context 'page_searcher_spec_data'
      include_context 'multiple_search_data'

      it 'finds a page that matches the search query by tags, language and text content' do
        expect(content_tag_language_searcher.search)
          .to match_array([
            matches_by_content_language_campaign_tags_layout,
            matches_by_content_language_tags_layout
          ])
      end

      it 'finds pages that match the search query by content, language, campaign and tags ' do
        expect(content_language_campaign_tags_searcher.search)
          .to match_array([
            matches_by_content_language_campaign_tags_layout
          ])
      end

      it 'does not find a match when the search parameters contain a liquid layout there is no match for' do
        expect(layout_searcher.search).to match_array([])
      end

      it 'finds pages when searching by matching tags and layout' do
        expect(layout_tags_searcher.search)
          .to match_array([
            matches_by_content_language_campaign_tags_layout,
            matches_by_content_language_tags_layout,
            content_tag_plugin_layout_match
          ])
      end

      context 'uses OR queries for categories where it makes sense (campaign, language) and not for other categories' do
        let(:finds_pages_for_all_campaigns) { Search::PageSearcher.new(campaign: [campaign.id, campaign2.id]) }
        let(:impossible_tag_searcher) { Search::PageSearcher.new(tags: Tag.all.pluck('id').push(Tag.last.id + 1)) }
        let(:campaign_language_searcher) do
          Search::PageSearcher.new(language: language, campaign: Campaign.all.pluck('id'))
        end

        it 'finds all pages that match the specified array of campaigns' do
          expect(finds_pages_for_all_campaigns.search).to match_array([
            content_tag_plugin_layout_match,
            title_language_campaign_match,
            matches_by_content_language_campaign_tags_layout,
            matches_by_content_language_campaign,
            matches_by_content_language_tags_layout
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

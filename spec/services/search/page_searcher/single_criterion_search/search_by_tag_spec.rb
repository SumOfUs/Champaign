# frozen_string_literal: true

require 'rails_helper'
require_relative '../page_searcher_spec_data.rb'

describe 'Search ::' do
  describe 'PageSearcher' do
    context 'searches by single criterion,' do
      context 'by tag' do
        include_context 'page_searcher_spec_data'
        let!(:has_many_tags) do
          create(:page,
                 title: 'a very taggy page',
                 tags: [alternative_tag, the_best_tag])
        end
        let!(:intersection_page_1) do
          create(:page,
                 title: 'has one same tag as intersection page 2',
                 slug: 'has-same-page-2',
                 tags: [tag1, tag2, tag3, tag4])
        end

        let!(:intersection_page_2) do
          create(:page,
                 title: 'has one same tag as intersection page 1',
                 slug: 'has-same-page-1',
                 tags: [tag3, tag4, tag5])
        end
        let(:tag_searcher) { Search::PageSearcher.new(tags: [tag.id]) }

        it 'searches for a page based on the tags on that page' do
          expect(tag_searcher.search).to match_array([content_tag_plugin_layout_match])
        end

        describe 'does not filter by tag when searching' do
          it 'with an empty tag array' do
            expect(Search::PageSearcher.new(tags: []).search).to match_array(Page.all)
          end
          it 'with tag array set to nil' do
            expect(Search::PageSearcher.new(tags: nil).search).to match_array(Page.all)
          end
          it 'with an empty string' do
            expect(Search::PageSearcher.new(tags: '').search).to match_array(Page.all)
          end
        end
        describe 'does not return any pages when searching' do
          it 'with a non-existent tag id' do
            expect(Search::PageSearcher.new(tags: [Tag.last.id + 1]).search).to match_array([])
          end
          it 'with an unused tag' do
            expect(Search::PageSearcher.new(tags: [unused_tag.id]).search).to match_array([])
          end
          it 'with a used tag and an unused tag' do
            expect(Search::PageSearcher.new(tags: [unused_tag.id, tag.id]).search).to match_array([])
          end

          it 'with two used tags never used on the same page' do
            expect(Search::PageSearcher.new(tags: [tag.id, alternative_tag.id]).search).to match_array([])
          end
        end

        describe 'returns one page when searching' do
          it "with a tag that's only assigned to that page" do
            expect(Search::PageSearcher.new(tags: [tag.id]).search).to match_array([content_tag_plugin_layout_match])
          end

          it "with one of that page's several tags" do
            expect(Search::PageSearcher.new(tags: [the_best_tag.id]).search).to match_array([has_many_tags])
          end

          it "with multiple of that page's tags in any order" do
            search = Search::PageSearcher.new(tags: [hipster_tag.id, unpopular_tag.id]).search
            expect(search).to match_array([single_return_page])

            search_reverse = Search::PageSearcher.new(tags: [unpopular_tag.id, hipster_tag.id]).search
            expect(search_reverse).to match_array([single_return_page])
          end

          it 'with a tag that matches two pages and a tag that matches one page' do
            page_searcher = Search::PageSearcher.new(tags: [alternative_tag.id, the_best_tag.id])
            expect(page_searcher.search).to match_array([has_many_tags])
          end
        end

        describe 'returns multiple pages when searching' do
          it 'with a tag as the only tag of both pages' do
            page_searcher = Search::PageSearcher.new(tags: [alternative_tag.id, the_best_tag.id])
            expect(page_searcher.search).to match_array([has_many_tags])
          end
          it 'with a tag used as one of several on both pages' do
            page_searcher = Search::PageSearcher.new(tags: [tag3.id])
            expect(page_searcher.search).to match_array([intersection_page_1, intersection_page_2])
          end
          it 'with multiple tags used as one of several on both pages' do
            page_searcher = Search::PageSearcher.new(tags: [tag3.id, tag4.id])
            expect(page_searcher.search).to match_array([intersection_page_1, intersection_page_2])
          end
        end
      end
    end
  end
end

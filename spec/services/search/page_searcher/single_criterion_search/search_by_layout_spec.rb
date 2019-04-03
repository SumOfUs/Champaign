# frozen_string_literal: true

require 'rails_helper'
require_relative '../page_searcher_spec_data.rb'

describe 'Search ::' do
  describe 'PageSearcher' do
    context 'searches by single criterion,' do
      context 'by layout' do
        include_context 'page_searcher_spec_data'
        let(:layout_searcher) { Search::PageSearcher.new(layout: [layout.id]) }

        it 'finds a page that contains the specified liquid layout' do
          expect(layout_searcher.search).to match_array([content_tag_plugin_layout_match])
        end

        describe 'returns all pages unfiltered when searching' do
          describe 'returns all pages when searching' do
            it 'with an empty array' do
              expect(Search::PageSearcher.new(layout: []).search).to match_array(Page.all)
            end
            it 'with nil' do
              expect(Search::PageSearcher.new(layout: nil).search).to match_array(Page.all)
            end

            it 'with an empty string' do
              expect(Search::PageSearcher.new(layout: '').search).to match_array(Page.all)
            end
          end
        end

        describe 'returns no pages when searching' do
          it 'with a non-existent layout' do
            expect(Search::PageSearcher.new(layout: [LiquidLayout.last.id + 1]).search).to match_array([])
          end
          it 'with an unused layout' do
            expect(Search::PageSearcher.new(layout: [unused_layout.id]).search).to match_array([])
          end
        end

        describe 'returns one page when searching' do
          it 'with a layout that only one page belongs to' do
            expect(Search::PageSearcher.new(layout: [messy_layout.id]).search).to match_array([single_return_page])
          end
        end

        describe 'returns some pages when searching' do
          it 'with a used layout and an unused layout' do
            expect(Search::PageSearcher.new(layout: [messy_layout.id, unused_layout.id]).search).to(
              match_array([single_return_page])
            )
          end
        end

        describe 'returns multiple pages when searching' do
          it 'with mutiple layouts that different pages belong to' do
            expect(Search::PageSearcher.new(layout: [messy_layout.id, twin_layout.id]).search).to(
              match_array([single_return_page, twin_page_1, twin_page_2])
            )
          end
          it 'with a layout that several pages belong to' do
            expect(Search::PageSearcher.new(layout: [twin_layout.id]).search).to(
              match_array([twin_page_1, twin_page_2])
            )
          end
        end
      end
    end
  end
end

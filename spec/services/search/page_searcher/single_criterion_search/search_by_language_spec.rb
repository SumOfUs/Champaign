# frozen_string_literal: true
require 'rails_helper'
require_relative '../page_searcher_spec_data.rb'

describe 'Search ::' do
  describe 'PageSearcher' do
    context 'searches by single criterion,' do
      context 'by language' do
        include_context 'page_searcher_spec_data'
        let(:language_searcher) { Search::PageSearcher.new(language: [language.id]) }
        it 'finds only the page that corresponds to the specified language' do
          expect(language_searcher.search).to match_array([title_language_campaign_match])
        end
        describe 'returns all pages unfiltered when searching' do
          describe 'returns all pages when searching' do
            it 'with an empty array' do
              expect(Search::PageSearcher.new(language: []).search).to match_array(Page.all)
            end
            it 'with nil' do
              expect(Search::PageSearcher.new(language: nil).search).to match_array(Page.all)
            end

            it 'with an empty string' do
              expect(Search::PageSearcher.new(language: '').search).to match_array(Page.all)
            end
          end
        end

        describe 'returns no pages when searching' do
          it 'with a non-existent language' do
            expect(Search::PageSearcher.new(language: [Language.last.id + 999]).search).to match_array([])
          end
          it 'with an unused language' do
            expect(Search::PageSearcher.new(language: [unused_language.id]).search).to match_array([])
          end
        end

        describe 'returns one page when searching' do
          it 'with a language that only one page belongs to' do
            expect(Search::PageSearcher.new(language: [french.id]).search).to match_array([single_return_page])
          end
        end

        describe 'returns some pages when searching' do
          it 'with a used language and an unused language' do
            expect(Search::PageSearcher.new(language: [french.id, unused_language.id]).search).to match_array([single_return_page])
          end
        end

        describe 'returns multiple pages when searching' do
          it 'with mutiple languages that different pages belong to' do
            expect(Search::PageSearcher.new(language: [french.id, german.id]).search).to match_array([single_return_page, twin_page_1, twin_page_2])
          end
          it 'with a language that several pages belong to' do
            expect(Search::PageSearcher.new(language: [german.id]).search).to match_array([twin_page_1, twin_page_2])
          end
        end
      end
    end
  end
end

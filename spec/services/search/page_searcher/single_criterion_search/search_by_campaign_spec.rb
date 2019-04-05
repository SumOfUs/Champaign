# frozen_string_literal: true

require 'rails_helper'
require_relative '../page_searcher_spec_data.rb'

describe 'Search ::' do
  describe 'PageSearcher' do
    context 'searches by single criterion,' do
      context 'by campaign' do
        include_context 'page_searcher_spec_data'
        let(:search_by_campaign) { Search::PageSearcher.new(campaign: [campaign.id]) }
        let!(:unused_campaign) { create(:campaign, name: 'unused campaign') }
        it 'searches for a page based on the campaign it belongs to' do
          expect(search_by_campaign.search).to match_array([title_language_campaign_match])
        end

        describe 'returns all pages when searching' do
          it 'with an empty array' do
            expect(Search::PageSearcher.new(campaign: []).search).to match_array(Page.all)
          end
          it 'with nil' do
            expect(Search::PageSearcher.new(campaign: nil).search).to match_array(Page.all)
          end

          it 'with an empty string' do
            expect(Search::PageSearcher.new(campaign: '').search).to match_array(Page.all)
          end
        end

        describe 'returns no pages when searching' do
          it 'with a non-existent campaign id' do
            expect(Search::PageSearcher.new(campaign: [Page.last.id + 1]).search).to match_array([])
          end
          it 'with an unused campaign id' do
            expect(Search::PageSearcher.new(campaign: [unused_campaign.id]).search).to match_array([])
          end
        end

        describe 'returns one page when searching' do
          it 'with a campaign that only contains one page' do
            expect(Search::PageSearcher.new(campaign: [unimpactful_campaign.id]).search).to(
              match_array([single_return_page])
            )
          end
        end

        describe 'returns some pages when searching' do
          it 'with a used campaign id and an unused campaign id' do
            expect(Search::PageSearcher.new(campaign: [unimpactful_campaign.id, unused_campaign.id]).search).to(
              match_array([single_return_page])
            )
          end
        end

        describe 'returns multiple pages when searching' do
          it 'with mutiple campaign ids that different pages belong to' do
            expect(Search::PageSearcher.new(campaign: [unimpactful_campaign.id, twin_campaign.id]).search).to(
              match_array([twin_page_1, twin_page_2, single_return_page])
            )
          end
          it 'with a campaign id that several pages belong to' do
            expect(Search::PageSearcher.new(campaign: [twin_campaign.id]).search).to(
              match_array([twin_page_1, twin_page_2])
            )
          end
        end
      end
    end
  end
end

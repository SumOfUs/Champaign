require 'rails_helper'
require_relative './search/page_searcher_spec_data.rb'

describe 'Search ::' do
  describe 'PageSearcher' do
    include_context 'page_searcher_spec_data'

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
  end
end

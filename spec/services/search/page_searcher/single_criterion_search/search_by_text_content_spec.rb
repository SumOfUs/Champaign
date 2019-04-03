# frozen_string_literal: true

require 'rails_helper'
require_relative '../page_searcher_spec_data.rb'

describe 'Search ::' do
  describe 'PageSearcher' do
    context 'searches by single criterion,' do
      context 'by text content' do
        include_context 'page_searcher_spec_data'
        let(:text_searcher) { Search::PageSearcher.new(content_search: test_text) }
        it 'gets pages that match by title or by text body if the text search method is called' do
          expect(text_searcher.search).to match_array([content_tag_plugin_layout_match, title_language_campaign_match])
        end
      end
    end
  end
end

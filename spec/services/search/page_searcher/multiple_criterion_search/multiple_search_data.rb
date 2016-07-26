RSpec.shared_context 'multiple_search_data' do

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
           slug: 'multimatch-page-1',
           language: language,
           campaign: campaign,
           tags: [create(:tag, name: 'ninja tag', actionkit_uri: '/foo/bar2')],
           liquid_layout: create(:liquid_layout))
  }

  let!(:matches_by_content_language_tags_layout) {
    create(:page,
           title: 'multimatch page 2',
           slug: 'multimatch-page-2',
           language: language,
           campaign: campaign2,
           tags: [tag],
           liquid_layout: layout)
  }

  let(:content_tag_language_params) {
    {
      content_search: 'multimatch',
      tags: [tag.id],
      language: language.id
    }
  }

  let(:content_language_campaign_tags_params) {
    {
      content_search: 'multimatch',
      language: language.id,
      campaign: campaign,
      tags: [tag.id]
    }
  }

  let(:layout_tags_searcher_params) {
    {
      tags: [tag.id],
      layout: layout
    }
  }

  let(:content_language_campaign_tags_searcher) { Search::PageSearcher.new(content_language_campaign_tags_params) }
  let(:content_tag_language_searcher) { Search::PageSearcher.new(content_tag_language_params) }
  let(:layout_searcher) { Search::PageSearcher.new(layout: [create(:liquid_layout, title:'tricky layout')]) }
  let(:layout_tags_searcher) { Search::PageSearcher.new(layout_tags_searcher_params) }

end

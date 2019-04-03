# frozen_string_literal: true

RSpec.shared_context 'page_searcher_spec_data' do
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
  let!(:layout) { create(:liquid_layout, :no_plugins) }
  let!(:unused_layout) { create(:liquid_layout, title: 'too bad for anyone to use, ever') }
  let!(:messy_layout) { create(:liquid_layout, title: 'has kinda tacky UX') }
  let!(:twin_layout) { create(:liquid_layout, title: 'Layout that has two pages associated with it') }
  let!(:language) { create(:language) }
  let!(:german) { create(:language, :german) }
  let!(:french) { create(:language, :french) }
  let!(:unused_language) { create(:language, code: 'NIL', name: 'Esperanto') }

  let!(:content_tag_plugin_layout_match) do
    create(:page,
           title: 'a non-matching title',
           language: build(:language, code: 'de', name: 'German'),
           tags: [tag],
           content: test_text,
           liquid_layout: layout,
           campaign: campaign2)
  end
  let!(:title_language_campaign_match) do
    create(:page,
           title: test_text + ' title!',
           language: language,
           campaign: campaign,
           tags: [alternative_tag])
  end

  let!(:single_return_page) do
    create(:page,
           title: 'a special snowflake',
           tags: [hipster_tag, unpopular_tag],
           language: french,
           campaign: unimpactful_campaign,
           liquid_layout: messy_layout)
  end

  let!(:twin_page_1) do
    create(:page,
           title: 'looks suspiciously like twin page 2',
           tags: [only_tag],
           language: german,
           campaign: twin_campaign,
           liquid_layout: twin_layout)
  end

  let!(:twin_page_2) do
    create(:page,
           title: 'looks suspiciously like twin page 1',
           tags: [only_tag],
           language: german,
           campaign: twin_campaign,
           liquid_layout: twin_layout)
  end

  let!(:page_that_doesnt_match_anything) do
    create(:page,
           title: 'Not a good match',
           tags: [
             create(:tag, name: 'tag not found', actionkit_uri: '/foo/404'),
             create(:tag, name: 'tag erroror', actionkit_uri: '/foo/500')
           ],
           content: 'totally arbitrary content',
           campaign: create(:campaign, name: 'a not very impactful test campaign'))
  end
  let!(:plugin) { create(:plugins_petition, page: content_tag_plugin_layout_match, active: true) }
end

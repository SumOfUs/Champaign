# frozen_string_literal: true

require 'rails_helper'

describe 'pages' do
  describe 'GET show' do
    let!(:page) { create(:page, title: 'I am a page', content: 'super awesome text content yo!') }

    it 'is case insensitive to campaign pages slugs' do
      get "/pages/#{page.slug.capitalize}"
      expect(response.status).to be 200
    end

    it 'redirects pages that really are not found' do
      get '/pages/randomslug'
      expect(response.status).to be 302
    end

    describe 'Mega tags' do
      it 'includes the default description meta tags' do
        get "/pages/#{page.slug}"
        expect(response.body).to include(I18n.t('branding.description'))
      end

      it 'includes the custom description meta tag if overriden' do
        page.update! meta_description: 'Custom description'
        get "/pages/#{page.slug}"
        expect(response.body).to include('Custom description')
      end
    end
  end

  describe 'POST create' do
    let(:english)     { create :language }
    let(:page_params) { { title: 'Away we go!', language_id: english.id } }
    before do
      login_as(create(:user), scope: :user)
    end

    it 'has the right follow-up url if liquid layout has a default follow-up url' do
      follow_up_layout = create :liquid_layout, default_follow_up_layout: nil
      liquid_layout = create :liquid_layout, default_follow_up_layout: follow_up_layout
      expect do
        post pages_path, params: { page: page_params.merge(liquid_layout_id: liquid_layout.id) }
      end.to change { Page.count }.by 1
      page = Page.last
      expect(PageFollower.new_from_page(page).follow_up_path).to eq "/a/#{page.slug}/follow-up"
    end

    it 'has a blank follow-up url if liquid layout has no default follow-up url' do
      liquid_layout = create :liquid_layout, default_follow_up_layout: nil
      expect do
        post pages_path, params: { page: page_params.merge(liquid_layout_id: liquid_layout.id) }
      end.to change { Page.count }.by 1
      page = Page.last
      expect(PageFollower.new_from_page(page).follow_up_path).to be_nil
    end
  end

  describe 'GET feeds' do
    let(:page) { Page.published.order('created_at desc').first }

    before do
      20.times { create(:page, publish_status: 'published', content: Faker::Lorem.paragraph_by_chars(550)) }
      2.times { create(:page, publish_status: 'unpublished') }
      get '/pages/feeds.rss'
      @feed = Feedjira::Feed.parse(response.body)
    end

    it 'should list published pages only' do
      expect(response.status).to be 200
      expect(response.content_type).to eq('application/rss+xml')
    end

    it 'should have proper title, description and link' do
      expect(@feed.title).to eql 'SumOfUs'
      expect(@feed.description).to eql 'stopping big corporations from behaving badly.'
    end

    it 'should list published feeds alone' do
      expect(@feed.entries.size).to eql 10
    end

    it 'should have proper feed data' do
      feed = @feed.entries.first
      expect(feed.title).to eql page.title
      # 500 chars + 7 chars for <p> opening and closing tag by feed
      expect(feed.summary.strip.length).to match 507
      expect(feed.published.strftime('%Y-%m-%d %I:%M:%S')).to match page.updated_at.strftime('%Y-%m-%d %I:%M:%S')
      expect(feed.url).to match "/a/#{page.slug}"
      expect(feed.entry_id).to match "/a/#{page.slug}"
    end

    it 'should by default have rss format' do
      get '/pages/feeds'
      expect(response.status).to be 200
      expect(response.content_type).to eq('application/rss+xml')
    end
  end
end

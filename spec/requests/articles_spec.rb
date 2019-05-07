# frozen_string_literal: true

require 'rails_helper'

describe 'articles' do
  before(:all) do
    3.times { create(:page, publish_status: 'published', content: Faker::Lorem.paragraph(3)) }
    2.times { create(:page, publish_status: 'unpublished') }
  end

  describe 'GET index' do
    let(:page) { Page.published.order('id desc').first }

    before do
      get '/articles.rss'
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
      expect(@feed.entries.size).to eql 3
    end

    it 'should have proper feed data' do
      feed = @feed.entries.first

      expect(feed.title).to eql page.title
      expect(feed.summary).to match page.content
      expect(feed.published.strftime('%Y-%m-%d %I:%M:%S')).to match page.updated_at.strftime('%Y-%m-%d %I:%M:%S')
      expect(feed.url).to match "/a/#{page.slug}"
      expect(feed.entry_id).to match "/a/#{page.slug}"
    end

    it 'should by default have rss format' do
      get '/articles'
      expect(response.status).to be 200
      expect(response.content_type).to eq('application/rss+xml')
    end
  end
end

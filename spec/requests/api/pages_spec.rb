# frozen_string_literal: true
require 'rails_helper'

describe 'api/pages' do
  def json
    JSON.parse(response.body)
  end

  let(:expected) do
    %w(
      id
      title
      slug
      content
      created_at
      updated_at
      publish_status
      campaign_action_count
      action_count
      language
      featured
      image
      url
    )
  end

  describe 'GET index' do
    before do
      create(:page, :published, title: 'Foo', content: 'Bar')
    end

    subject { JSON.parse(response.body) }

    before { get('/api/pages.json') }

    it 'returns list of pages' do
      expect(subject.size).to eq(1)

      expect(subject.first.keys).to match_array(expected)

      expect(subject.first.symbolize_keys).to include(title: 'Foo',
                                                      content: 'Bar')
    end
  end

  describe 'GET featured' do
    before do
      create(:page, :published, featured: true, title: 'Foo', content: 'Bar')
      create(:page, featured: false)
    end

    subject { JSON.parse(response.body) }

    before { get(featured_api_pages_path(format: :json)) }

    it 'returns list of pages' do
      expect(subject.size).to eq(1)

      expect(subject.first.keys).to match_array(expected)

      expect(subject.first.symbolize_keys).to include(title: 'Foo',
                                                      content: 'Bar')
    end
  end

  describe 'GET show' do
    let(:page) { create(:page, title: 'Foo', content: 'Bar') }

    subject { JSON.parse(response.body) }

    before { get(api_page_path(page, format: :json)) }

    it 'returns page' do
      expected = %w(
        id
        title
        slug
        content
        created_at
        updated_at
        publish_status
        featured
        action_count
        language
        campaign_action_count
      )
      expect(subject.keys).to match_array(expected)

      expect(subject.symbolize_keys).to include(title: 'Foo',
                                                id: page.id)
    end
  end
end

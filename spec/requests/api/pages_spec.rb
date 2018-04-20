# frozen_string_literal: true

require 'rails_helper'

describe 'api/pages' do
  def json
    JSON.parse(response.body)
  end

  let(:expected) do
    %w[
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
    ]
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
      expected = %w[
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
      ]
      expect(subject.keys).to match_array(expected)
      expect(subject.symbolize_keys).to include(title: 'Foo',
                                                id: page.id)
    end
  end

  describe 'GET actions' do
    let(:page) { create :page }
    let!(:actions) do
      %i[default published hidden].map do |status|
        create :action, page: page, publish_status: status, form_data: { action_foo: status }
      end
    end

    subject { get api_page_actions_path(page) }

    it 'returns a 403 if the page publish_actions is secure' do
      page.update!(publish_actions: :secure)
      subject
      expect(response.code).to eq '403'
      expect(response.body).to be_empty
    end

    it 'returns published and default actions if page publish_actions is default_published' do
      page.update!(publish_actions: :default_published)
      subject
      expect(response.code).to eq '200'
      expected = [
        { action_foo: 'published', publish_status: 'published', id: actions[1].id },
        { action_foo: 'default', publish_status: 'default', id: actions[0].id }
      ]
      expect(json.deep_symbolize_keys[:actions]).to match_array(expected)
    end

    it 'returns only published pages if page publish_actions is default_hidden' do
      page.update!(publish_actions: :default_hidden)
      subject
      expect(response.code).to eq '200'
      expected = [{ action_foo: 'published', publish_status: 'published', id: actions[1].id }]

      expect(json.deep_symbolize_keys[:actions]).to match_array(expected)
    end

    it 'returns a hash with the names of the headers' do
      page.update!(publish_actions: :default_hidden)
      subject
      expect(response.code).to eq '200'
      expected = { action_foo: 'Foo', publish_status: 'Publish Status', id: 'Id' }
      expect(json.deep_symbolize_keys[:headers]).to eq(expected)
    end

    it 'will paginate according to parameters that are passed to it' do
      page.update!(publish_actions: :default_published)
      get api_page_actions_path(page, page_number: 2, per_page: 1)
      expect(response.code).to eq '200'
      expect(json.symbolize_keys[:actions].size).to eq 1
    end
  end

  describe 'GET /similar' do
    let(:name_tag) { create :tag, name: 'TuuliP' }
    let(:region_tag) { create :tag, name: '@Global' }
    let(:issue_tag1) { create :tag, name: '#AnimalRights' }
    let(:issue_tag2) { create :tag, name: '#Sexism' }
    let(:english) { create :language, :english }
    let(:french) { create :language, :french }

    let!(:original_page) do
      create(:page,
             :published,
             id: 123,
             title: 'Coolest petition',
             content: 'Coolest petition content',
             language: english,
             tags: [name_tag, region_tag, issue_tag1, issue_tag2])
    end

    context 'valid request' do
      context 'similar pages exist' do
        let!(:similar_french_page) do
          create(:page,
                 :published,
                 title: 'Je ne parle pas français',
                 language: french,
                 tags: [name_tag, region_tag, issue_tag1, issue_tag2])
        end

        let!(:similar_page) do
          create(:page,
                 :published,
                 title: 'A similar petition',
                 content: 'Also cool content',
                 language: english,
                 tags: [name_tag, region_tag, issue_tag1, issue_tag2])
        end

        let!(:similar_unpublished) do
          create(:page,
                 :unpublished,
                 title: 'Similar but unpublished',
                 language: english,
                 tags: [name_tag, region_tag, issue_tag1, issue_tag2])
        end

        let!(:one_issue_tag_page) do
          create(:page,
                 :published,
                 title: 'One tag match',
                 language: english,
                 tags: [name_tag, region_tag, issue_tag1])
        end

        subject { get(api_page_similar_path(original_page, number: 3, format: :json)) }

        it 'returns pages with tags that are similar to the original page' do
          subject
          expect(response.code).to eq '200'
          expect(json_hash.first.keys).to match_array(expected)
          expect(json_hash.first.symbolize_keys).to include(title: 'A similar petition',
                                                            content: 'Also cool content')
        end

        it 'does not return pages that have no matching issue tag' do
        end

        it 'does not return pages that match by tags but are different language' do
        end

        it 'returns the specified number of pages' do
        end

        it 'does not return unpublished pages' do
        end
      end

      context 'insufficient number of similar pages' do
        it 'falls back to pages with fewer matching issue tags if there are otherwise not enough similar pages' do
        end

        it 'falls back to recent featured petitions with the same region tag if there are no matches by issue tag' do
        end
      end
    end

    context 'the requested page does not exist' do
      it 'responds with 404' do
        get('/api/pages/similar/')
        expect(response.code).to eq '404'
      end
    end
  end
end

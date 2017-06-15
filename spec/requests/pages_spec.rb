# frozen_string_literal: true
require 'rails_helper'

describe 'pages' do
  let(:english)     { create :language }
  let(:page_params) { { title: 'Away we go!', language_id: english.id } }
  let!(:page) { create(:page, title: 'I am a page', content: 'super awesome text content yo!') }

  describe 'GET show' do
    it 'is case insensitive to campaign pages slugs' do
      get "/pages/#{page.slug.capitalize}"
      expect(response.status).to be 200
    end

    it 'redirects pages that really are not found' do
      get '/pages/randomslug'
      expect(response.status).to be 302
    end
  end

  describe 'POST create' do
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
end

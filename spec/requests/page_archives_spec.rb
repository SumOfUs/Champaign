# frozen_string_literal: true

require 'rails_helper'

describe 'Page archiving' do
  before do
    login_as(create(:user), scope: :user)
  end

  describe 'POST /page/:id/archive' do
    let!(:page) { create(:page, publish_status: 'published') }

    it 'archives the page' do
      post "/pages/#{page.id}/archive"
      page.reload
      expect(page.publish_status).to eql('archived')
    end

    it 'redirects to index page' do
      post "/pages/#{page.id}/archive"
      expect(response).to redirect_to pages_path
    end
  end

  describe 'DELETE /page/:id/archive' do
    let!(:page) { create(:page, publish_status: 'published') }

    it 'unarchives the page' do
      delete "/pages/#{page.id}/archive"
      page.reload
      expect(page.publish_status).to eql('unpublished')
    end

    it 'redirects to index page' do
      post "/pages/#{page.id}/archive"
      expect(response).to redirect_to pages_path
    end
  end
end

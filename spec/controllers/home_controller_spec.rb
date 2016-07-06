require 'rails_helper'

describe HomeController do
  it 'responds with 200 to a health check' do
    get :health_check
    expect(response.status).to be 200
  end

  it 'has a route for robots.txt' do
    get :robots, format: 'txt'
    expect(response.status).to be 200
  end

  context 'get index' do
    it 'routes to homepage  if requested by an unauthenticated user' do
      allow(controller).to receive(:user_signed_in?) { false }
      expect(get :index).to redirect_to(Settings.home_page_url)
    end

    it 'routes to /pages if requested by an authenticated user' do
      allow(controller).to receive(:user_signed_in?) { true }
      expect(get :index).to redirect_to(pages_path)
    end

  end


end

# frozen_string_literal: true

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
end

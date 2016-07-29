# frozen_string_literal: true
require 'rails_helper'

describe 'API::Stateless Authentication' do
  include Requests::RequestHelpers

  let(:member) { create :member }

  before :each do
    member.create_authentication(password: 'password')
  end

  context 'Password Authentication' do
    it 'returns a 400 Bad Request when called with invalid parameters' do
      post '/api/stateless/auth/password'
      expect(response.status).to eq(400)
      expect(json.error.message).to match(/invalid parameters/i)
    end

    it 'returns a 401 Unauthorized when credentials are wrong' do
      credentials = { email: 'invalid', password: 'invalid' }
      post('/api/stateless/auth/password', credentials: credentials)
      expect(response.status).to eq(401)
    end

    it 'returns a 200 OK when authentication is successful' do
      credentials = { email: member.email, password: 'password' }
      post('/api/stateless/auth/password', credentials: credentials)
      expect(response.status).to eq(200)
    end

    it 'returns a token and the member when authentication is successful' do
      JWT_REGEX = /^[a-zA-Z0-9\-_]+\.[a-zA-Z0-9\-_]+\.([a-zA-Z0-9\-_]+)?$/ 
      credentials = { email: member.email, password: 'password' }
      post('/api/stateless/auth/password', credentials: credentials)
      expect(json.token).to match(JWT_REGEX)
      expect(json.member.email).to eq(member.email)
    end
  end

  context 'When a route requires authentication' do
    it 'returns 401 Unauthorized if no valid token was provided' do
      get('/api/stateless/auth/test_authentication')
      expect(response.status).to eq(401)
    end

    it 'returns 200 OK if a valid token was provided' do
      credentials = { email: member.email, password: 'password' }
      post('/api/stateless/auth/password', credentials: credentials)
      headers = { authorization: "Bearer #{json.token}" }
      get('/api/stateless/auth/test_authentication', nil, headers)

      expect(response.status).to eq(200)
    end
  end
end

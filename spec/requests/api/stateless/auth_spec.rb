# frozen_string_literal: true
require 'rails_helper'

describe 'API::Stateless Authentication' do
  include Requests::RequestHelpers
  include AuthToken

  let(:member) { create :member }

  before :each do
    member.create_authentication(password: 'password', confirmed_at: Time.now)
  end

  context 'Password Authentication' do
    it 'returns a 400 Bad Request when called with invalid parameters' do
      post '/api/stateless/auth/password'
      expect(response.status).to eq(400)
      expect(json_ostruct.error.message).to match(/invalid parameters/i)
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

    it 'returns the member when authentication is successful' do
      credentials = { email: member.email, password: 'password' }
      post('/api/stateless/auth/password', credentials: credentials)
      expect(json_ostruct.member.email).to eq(member.email)
    end

    it 'returns a valid JWT token when authentication is successful' do
      credentials = { email: member.email, password: 'password' }
      post('/api/stateless/auth/password', credentials: credentials)
      expect { decode_jwt(json_ostruct.token) }.to_not raise_error
    end
  end

  context 'When a route requires authentication' do
    it 'returns 401 Unauthorized if no valid token was provided' do
      get('/api/stateless/auth/test_authentication')
      expect(response.status).to eq(401)
    end

    it 'returns 401 Unauthorized if the token is expired' do
      token = encode_jwt(member.token_payload, -1)
      headers = { authorization: "Bearer #{token}" }
      get('/api/stateless/auth/test_authentication', nil, headers)

      expect(response.status).to eq(401)
    end

    it 'returns 200 OK if a valid token was provided' do
      token = encode_jwt(member.token_payload, 0.5)
      headers = { authorization: "Bearer #{token}" }
      get('/api/stateless/auth/test_authentication', nil, headers)

      expect(response.status).to eq(200)
    end
  end
end

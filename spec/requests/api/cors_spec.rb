# frozen_string_literal: true
require 'rails_helper'

describe 'CORS support' do
  let(:allow_origin) do
    response.headers['Access-Control-Allow-Origin']
  end

  let(:allow_methods) do
    response.headers['Access-Control-Allow-Methods']
  end

  let(:allow_credentials) do
    response.headers['Access-Control-Allow-Credentials']
  end

  it 'responds to OPTIONS with a 204 No Content' do
    options('/api/pages')
    expect(response.status).to eq(204)
  end

  # Note that there are no controller methods to handle any OPTIONS
  # requests. This tests that all existing routes are matched via: OPTIONS
  # and responded to accordigly.
  describe 'Preflight requests (OPTIONS)' do
    context 'when a request comes *.sumofus.org subdomain' do
      headers = {
        accept: 'application/json',
        origin: 'http://actions.sumofus.org'
      }

      it 'responds allowing the exact subdomain' do
        options('/api/pages', nil, headers)
        expect(allow_origin).to eq('http://actions.sumofus.org')
      end

      it 'also allows requests from sumofus.org (no subdomain)' do
        options('/api/pages', nil, accept: 'application/json', origin: 'http://sumofus.org')
        expect(allow_origin).to eq('http://sumofus.org')
      end

      it 'allows all HTTP methods' do
        options('/api/pages', nil, headers)
        expect(allow_methods).to match(/(GET|POST|PUT|DELETE|OPTIONS|PATCH)/)
      end

      it 'allows all Credentials' do
        options('/api/pages', nil, headers)
        expect(allow_credentials).to eq('true')
      end
    end

    context 'when the origin is not a *.sumofus.org subdomain' do
      headers = { origin: 'http://www.not-sumofus.org' }

      it 'does not have the allow-origin cors header' do
        options('/api/pages', nil, headers)
        expect(allow_origin).to be_nil
      end

      it 'does not have the allow-methods cors header' do
        options('/api/pages', nil, headers)
        expect(allow_methods).to be_nil
      end

      it 'does not have the allow-credentials cors header' do
        options('/api/pages', nil, headers)
        expect(allow_credentials).to be_nil
      end
    end
  end

  # This block only tests one GET request, but the same applies to
  # all existing routes that are handled by a controller method
  describe 'Any other http request' do
    context 'when a request comes *.sumofus.org subdomain' do
      headers = {
        accept: 'application/json',
        origin: 'https://actions.sumofus.org'
      }

      it 'responds allowing the exact domain' do
        get('/api/pages', nil, headers)
        expect(allow_origin).to eq('https://actions.sumofus.org')
      end
    end

    context 'when the origin is not a *.sumofus.org subdomain' do
      headers = {
        accept: 'application/json',
        origin: 'http://www.not-sumofus.org'
      }

      it 'responds without the CORS headers' do
        get('/api/pages', nil, headers)
        expect(allow_origin).to be_nil
        expect(response.status).to be(200)
      end
    end
  end
end

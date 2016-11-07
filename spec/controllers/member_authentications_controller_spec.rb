# frozen_string_literal: true
require 'rails_helper'

describe MemberAuthenticationsController do
  describe 'POST create' do
    let(:auth) { double('auth', valid?: true, member_id: 34) }
    let(:page) { double('page', slug: 'heyo', page_id: '1', language: double('language', code: 'en')) }

    before do
      allow(MemberAuthenticationBuilder).to receive(:build) { auth }
      allow(Page).to receive(:first) { page }

      session[:follow_up_url] = '/a/b'
      post :create, email: 'test@example.com', password: 'p', password_confirmation: 'p'
    end

    it 'builds authentication' do
      expect(MemberAuthenticationBuilder).to have_received(:build)
        .with(password: 'p', password_confirmation: 'p', email: 'test@example.com', language_code: 'en')
    end

    # TODO: test it's being set from cookies
    xit 'sets locale' do
      expect(I18n).to have_received(:locale=).with('en')
    end

    context 'successfully creates authentication' do
      it 'returns with js snippet to redirect that includes member id' do
        expect(response.body).to match("window.location = '/a/b'")
      end

      it 'sets flash notice' do
        expect(flash[:notice]).to match(/click the confirmation link/)
      end
    end

    context 'unsuccessfully creates authentication' do
      let(:auth) { double('auth', valid?: false, errors: [{ foo: :bar }]) }

      it 'returns errors as json' do
        expect(response.status).to eq(422)
        expect(response.body).to eq({ errors: [{ foo: :bar }] }.to_json)
      end
    end
  end
end

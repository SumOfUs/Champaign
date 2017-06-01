# frozen_string_literal: true
require 'rails_helper'

describe 'Email Confirmation when signing up to express donations' do
  let!(:member) { create(:member, email: 'test@example.com', actionkit_user_id: 'actionkit_wohoo') }
  let!(:auth) { create(:member_authentication, token: '1234', member: member) }

  subject { get "/email_confirmation?#{params.to_query}" }

  context 'success' do
    let(:params) do
      { params:
        {
          token: auth.token,
          email: 'test@example.com',
          language: 'EN'
        }
      }
    end

    it 'confirms user authentication' do
      subject
      expect(response.body).to include('successfully confirmed your account')
      expect(auth.reload.confirmed_at).to_not be_nil
    end

    it 'sets html#lang to locale' do
      subject
      expect(response.body).to match(/html lang="en"/)
    end
  end

  describe 'locale' do
    let(:params) do
      { params:
        { token: auth.token,
          email: 'test@example.com',
          language: 'de'
        }
      }
    end

    it 'sets locale to passed language code' do
      subject
      expect(I18n.locale).to eq(:de)
    end
  end

  context 'failure' do
    params = { token: 'nosuchtoken',
               email: 'test@example.com',
               language: 'EN' }

    it 'renders error' do
      get "/email_confirmation?#{params.to_query}"
      expect(response.body).to match(/there was an issue confirming your account/)
      expect(auth.reload.confirmed_at).to be nil
    end
  end

  context 'with missing memeber' do
    it 'renders error' do
      expect do
        get '/email_confirmation'
      end.to raise_error(ActiveRecord::RecordNotFound)

      expect do
        get '/email_confirmation', email: 'no@example.com'
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end

# frozen_string_literal: true
require 'rails_helper'

describe 'Email Confirmation when signing up to express donations' do
  let!(:member) { create(:member, email: 'test@example.com', actionkit_user_id: 'actionkit_wohoo') }
  let!(:auth) { create(:member_authentication, token: '1234', member: member) }

  context 'success' do
    let(:params) do
      { token: auth.token,
        email: 'test@example.com',
        language: 'EN' }
    end

    subject { get "/email_confirmation?#{params.to_query}" }

    it 'confirms user authentication' do
      subject
      expect(response.body).to include('successfully confirmed your account')
      expect(auth.reload.confirmed_at).to_not be_nil
    end

    it 'pushes a member update to the ActionKit queue' do
      expect(ChampaignQueue).to receive(:push).with(type: 'update_member',
                                                    params: {
                                                      akid: 'actionkit_wohoo',
                                                      fields: {
                                                        express_account: 1
                                                      }
                                                    })
      subject
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
end

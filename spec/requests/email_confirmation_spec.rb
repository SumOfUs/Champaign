# frozen_string_literal: true
require 'rails_helper'

describe 'Email Confirmation when signing up to express donations' do
  let!(:auth) do
    create(:member_authentication, token: '1234')
  end

  it 'confirms user authentication if the token matches' do
    get '/email_confirmation?token=1234'

    expect(response.body).to include('You have successfully signed up for express donations')
    expect(auth.reload.confirmed_at).to_not be_nil
  end

  it 'renders error if the token does not match' do
    get '/email_confirmation?token=abcd'

    expect(response.body).to match(/issue signing up for express donations/)
    expect(auth.reload.confirmed_at).to be nil
  end
end

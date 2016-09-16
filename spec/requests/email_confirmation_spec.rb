# frozen_string_literal: true
require 'rails_helper'

describe 'Email Confirmation when signing up to express donations' do
  let!(:member) do
    create(:member,
           email: 'test@example.com',
           authentication: create(:member_authentication,
                                  password: 'password',
                                  token: 'imarealtoken1235'))
  end

  it 'Authenticates the user if the token and email it gets match on a member authentication record' do
    get '/email_confirmation?email=test%40example.com&amp;token=imarealtoken1235'
    expect(response.body).to include('You have successfully signed up for express donations')
  end

  it 'Logs an error and renders errors if the token and email address do not match' do
    expect(Rails.logger).to receive(:error).with(
                              'Token verification failed for email test@example.com with token iamnotarealtoken.'
                            )
    get '/email_confirmation?email=test%40example.com&amp;token=iamnotarealtoken'
    expect(response.body).to include(
                               'There was an issue signing up for express donations.',
                               'Your confirmation token appears to be invalid.'
                             )
  end
end

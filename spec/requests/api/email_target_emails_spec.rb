require 'rails_helper'

describe 'Email Target Emails' do
  let!(:page) { create(:page, title: 'Foo Bar', slug: 'foo-bar') }

  describe 'GET index' do
    before do
      allow_any_instance_of(Aws::DynamoDB::Client).to receive(:query)
        .and_return(
          instance_double('Response', items: [], last_evaluated_key: nil)
        )

      login_as(create(:user), scope: :user)
    end

    it 'returns found' do
      get "/api/email_target_emails?slug=#{page.slug}"
      expect(response).to have_http_status(:ok)
    end

    it 'fetches records from DynamoDB' do
      expect_any_instance_of(Aws::DynamoDB::Client)
        .to receive(:query).with(hash_including(index_name: 'Slug-CreatedAt-index'))

      get "/api/email_target_emails?slug=#{page.slug}"
    end
  end

  describe 'POST download' do
    before do
      allow_any_instance_of(Aws::SNS::Client).to receive(:publish)

      login_as(create(:user), scope: :user)
    end

    it 'post message to SNS topic' do
      expect_any_instance_of(Aws::SNS::Client).to receive(:publish)
        .with(hash_including(message: /"email":"foo@example.com","slug":"foo-bar"/))

      post '/api/email_target_emails/download', params: { email: 'foo@example.com', slug: 'foo-bar' }
    end
  end
end

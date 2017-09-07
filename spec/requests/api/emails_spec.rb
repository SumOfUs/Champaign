require 'rails_helper'

describe 'Emails', type: :request do
  describe 'POST /emails' do
    let!(:page) { create(:page, title: 'Foo Bar', slug: 'foo-bar') }
    let!(:plugin) do
      create(:email_tool,
             page: page,
             from_email_address: create(:registered_email_address),
             use_member_email: true,
             targets: build_list(:email_tool_target, 1))
    end

    context 'given valid params' do
      let(:params) do
        { email: {
          body: 'Lorem ipsum',
          subject: 'A Subject',
          from_email: 'john@email.com',
          from_name: 'John Doe'
        } }
      end

      before do
        allow_any_instance_of(Aws::DynamoDB::Client).to receive(:put_item)
      end

      it 'returns 200 OK' do
        post "/api/pages/#{page.id}/emails", params: params
        expect(response).to have_http_status(:ok)
      end

      it 'sends an email with the expected params' do
        target = plugin.targets.first
        from_email = plugin.from_email_address
        expect_any_instance_of(Aws::DynamoDB::Client).to receive(:put_item)
          .with(
            table_name: Settings.dynamodb_mailer_table,
            item: {
              MailingId: /foo-bar:\d*/,
              UserId: 'john@email.com',
              Body: '<p>Lorem ipsum</p>',
              Subject: 'A Subject',
              ToEmails: "#{target.name} <#{target.email}>",
              FromName: 'John Doe',
              FromEmail: 'john@email.com',
              ReplyTo: "#{from_email.name} <#{from_email.email}>, John Doe <john@email.com>"
            }
          )
        post "/api/pages/#{page.id}/emails", params: params
      end

      it 'creates an action'

      it 'publishes an event'
    end

    context 'given invalid params' do
      let(:params) do
        { email: { body: 'Lorem ipsum' } }
      end

      it 'returns 422 Unprocessable entity' do
        post "/api/pages/#{page.id}/emails", params: params
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns a json response with the error messages' do
        post "/api/pages/#{page.id}/emails", params: params
        errors = response_json['errors']
        expect(errors).to be_present
        expect(errors['from_name']).to include("can't be blank")
        expect(errors['from_email']).to include("can't be blank")
        expect(errors['subject']).to include("can't be blank")
      end
    end
  end
end

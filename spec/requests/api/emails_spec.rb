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
        {
          email: {
            body: 'Suspendisse vestibulum dolor et libero sollicitudin aliquam eu eu purus. Phasellus eget diam in felis
        gravida mollis a vitae velit. Duis tempus dolor non finibus convallis. In in ipsum lacinia, pulvinar lectus nec,
        condimentum sapien. Nunc non dui dolor. Ut ornare pretium nunc sed ornare. Praesent at risus a felis lacinia
        pretium et a neque. Nam non mi in eros sollicitudin imperdiet.',
            subject: 'A Subject',
            from_email: 'john@email.com',
            from_name: 'John Doe',
            country: 'US'
          }
        }
      end

      before do
        allow_any_instance_of(Aws::DynamoDB::Client).to receive(:put_item)
      end

      it 'returns 200 OK' do
        post "/api/pages/#{page.id}/emails", params: params
        expect(response).to have_http_status(:ok)
      end

      it 'sends an email with the expected params' do
        Timecop.freeze do
          expect_any_instance_of(Aws::DynamoDB::Client).to receive(:put_item)
            .with(
              table_name: Settings.dynamodb_mailer_table,
              item: hash_including(MailingId: /foo-bar:\d*/,
                                   UserId: 'john@email.com',
                                   Subject: 'A Subject',
                                   Slug: 'foo-bar',
                                   Body: /dolor et libero/,
                                   Recipients: [{ name: /\w/, email: /[\w@.]/ }],
                                   Sender: { name: 'John Doe', email: 'john@email.com' })
            )
          post "/api/pages/#{page.id}/emails", params: params
        end
      end

      it 'creates an action' do
        expect {
          post "/api/pages/#{page.id}/emails", params: params
        }.to change(Action, :count).by(1)
      end

      it 'creates a member (given the country is not EEA)' do
        expect {
          post "/api/pages/#{page.id}/emails", params: params
        }.to change(Member, :count).by(1)

        member = Member.last

        expect(member.email).to eq 'john@email.com'
        expect(member.first_name).to eq 'John'
        expect(member.last_name).to eq 'Doe'
        expect(member.country).to eq 'US'
      end

      it 'publishes an event (given the country is not EEA)' do
        akid = '25429.9032842.RNP4O4'
        payload = hash_including(
          type: 'action',
          params: hash_including(
            page: 'foo-bar-petition',
            name: 'John Doe',
            source: 'fb',
            akid: akid,
            country: 'United States'
          )
        )

        expect(ChampaignQueue).to receive(:push).with(
          payload,
          group_id: /action:\d+/
        )

        params[:tracking_params] = { source: 'fb', akid: akid }
        post "/api/pages/#{page.id}/emails", params: params
      end
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

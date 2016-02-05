require 'rails_helper'

describe "Api Actions" do
  let(:sqs_client) { double }

  before do
    allow(Aws::SQS::Client).to receive(:new){ sqs_client }
    allow(sqs_client).to receive(:send_message)
    allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("production"))
  end

  describe "POST#create" do
    let(:page) { create(:page) }
    let(:form) { create(:form_with_email) }
    let(:params) do
      {
        email:   'hello@example.com',
        form_id: form.id,
        source:  'fb',
        akid:    '123.456.fcvd'
      }
    end

    describe 'akid manipulation' do
      before do
        post "/api/pages/#{page.id}/actions", params
      end

      it 'persists action' do
        expect(page.actions.count).to eq(1)
      end

      it 'saves akid' do
        expect(
            Action.where('form_data @> ?', { akid: '123.456.fcvd' }.to_json).first
        ).to eq(page.actions.first)
      end

      it "Posts action to SQS Queue" do
        expected_params = {
            queue_url: 'http://example.com',

            message_body: {
                type: "action",
                params: {
                    slug: page.slug,
                    body: {
                        email:      "hello@example.com",
                        page_id:    page.id.to_s,
                        form_id:    form.id.to_s,
                        source:     'fb',
                        akid:       '123.456.fcvd'
                    }
                }
            }.to_json
        }

        expect(sqs_client).to have_received(:send_message).with(expected_params)
      end
    end

    describe 'referring akid' do
      it 'posts a referring user if one is provided' do
        updated_params = params
        updated_params[:referring_akid] = updated_params.delete :akid
        post "/api/pages/#{page.id}/actions", params
        expected_params = {
            queue_url: 'http://example.com',

            message_body: {
                type: 'action',
                params: {
                    slug: page.slug,
                    body: {
                        email:          'hello@example.com',
                        page_id:        page.id.to_s,
                        form_id:        form.id.to_s,
                        source:         'fb',
                        referring_user: '/rest/v1/user/456/'
                    }
                }
            }.to_json
        }

        expect(sqs_client).to have_received(:send_message).with(expected_params)
      end
    end
  end
end


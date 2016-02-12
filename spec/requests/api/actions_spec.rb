require 'rails_helper'

describe "Api Actions" do
  let(:sqs_client) { double }

  before do
    allow(Aws::SQS::Client).to receive(:new) { sqs_client }
    allow(sqs_client).to receive(:send_message)
    allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("production"))
  end

  describe "POST#create" do
    let(:page) { create(:page) }
    let(:form) { create(:form_with_email) }

    let(:params) do
      {
          email:    'hello@example.com',
          form_id:  form.id,
          source:   'fb',
          akid:     '123.456.fcvd',
          referring_akid: '123.456.xyz'
      }
    end

    let(:message_body) do
      {
        type: "action",

        params: {
          page:   "#{page.slug}-petition",
          email:  "hello@example.com",
          page_id: page.id.to_s,
          form_id: form.id.to_s,
          source: 'fb',
          akid:   '123.456.fcvd',
          referring_akid: '123.456.xyz'
        }
      }
    end

    let(:expected_queue_payload) do
      {
        queue_url: 'http://example.com',
        message_body: message_body.to_json
      }
    end

    describe 'akid manipulation' do
      context 'new member' do
        before do
          post "/api/pages/#{page.id}/actions", params
        end

        it 'persists action' do
          expect(page.actions.count).to eq(1)
        end

        it 'saves akid on action' do
          expect(
              Action.where('form_data @> ?', {akid: '123.456.fcvd'}.to_json).first
          ).to eq(page.actions.first)
        end

        it 'saves actionkit_user_id on member' do
          expect(Member.last.actionkit_user_id).to eq '456'
        end

        it 'posts action to SQS Queue' do
          expect(sqs_client).to have_received(:send_message).with(expected_queue_payload)
        end
      end

      context 'existing member' do
        let!(:member) { create :member, actionkit_user_id: '7777', email: params[:email]}

        it 'overwrites existing actionkit_user_id' do
          post "/api/pages/#{page.id}/actions", params
          expect(member.reload.actionkit_user_id).to eq '456'
        end
      end

    end

    describe 'referring akid' do
      before do
        params[:referring_akid] = '123.456.xyz'
      end

      it 'posts a referring akid' do
        post "/api/pages/#{page.id}/actions", params
        expect(sqs_client).to have_received(:send_message).with(expected_queue_payload)
      end
    end
  end

  ['long_string_with_underscore', '1234.5678', '2', '?&=', '2..2', '..2'].each do |invalid_akid|
    describe "invalid akid '#{invalid_akid}'" do
      let(:page) { create(:page) }
      let(:form) { create(:form_with_email) }
      let(:params) do
        {
            email: 'hello@example.com',
            form_id: form.id,
            akid: invalid_akid
        }
      end

      context 'existing member' do

        let(:member) { create :member, actionkit_user_id: '1234', email: params[:email]}

        it 'does not overwrite existing actionkit_user_id' do
          post "/api/pages/#{page.id}/actions", params
          expect(member.reload.actionkit_user_id).to eq '1234'
        end

      end

      context 'new member' do
        before do
          post "/api/pages/#{page.id}/actions", params
        end

        it 'responds with success' do
          expect(response).to be_success
        end

        it 'does not assign an actionkit_user_id to the created Member' do
          expect(Member.first.actionkit_user_id).to be_blank
        end

        it 'sends the bad akid through the form data for record keeping' do
          expect(Action.where('form_data @> ?', {akid: invalid_akid}.to_json).first).to eq(page.actions.first)
        end

        it 'does not include a referring_user_uri in the queue message' do
          expected_params = {
              queue_url: 'http://example.com',

              message_body: {
                  type: 'action',
                  params: {
                      page: "#{page.slug}-petition",
                      email: 'hello@example.com',
                      page_id: page.id.to_s,
                      form_id: form.id.to_s,
                      akid: invalid_akid
                  }
              }.to_json
          }
          expect(sqs_client).to have_received(:send_message).with(expected_params)
        end
      end
    end
  end
end

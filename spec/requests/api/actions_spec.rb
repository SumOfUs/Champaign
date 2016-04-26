require 'rails_helper'

describe "Api Actions" do
  RSpec::Matchers.define :country_field_set_as do |country|
    match do |actual|
      JSON.parse(actual[:message_body])['params']['country'] === country
    end
  end

  let(:sqs_client) { double }

  before do
    allow(Aws::SQS::Client).to receive(:new) { sqs_client }
    allow(sqs_client).to receive(:send_message)
    allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("production"))
  end

  let(:page) { create(:page) }
  let(:form) { create(:form_with_email) }

  describe "POST#create" do
    let(:page) { create(:page) }
    let(:form) { create(:form_with_email_and_optional_country) }

    let(:params) do
      {
        email:    'hello@example.com',
        form_id:  form.id,
        source:   'fb',
        akid:      '1234.5678.tKK7gX',
        referring_akid:  '1234.5678.tKK7gX'
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
          akid:   '1234.5678.tKK7gX',
          referring_akid: '1234.5678.tKK7gX',
          mobile: 'desktop',
          referer: nil,
          user_en: 1
        }
      }
    end

    let(:expected_queue_payload) do
      {
        queue_url: 'http://example.com',
        message_body: message_body.to_json
      }
    end

    context 'for imported page' do
      let(:page) { create(:page, status: 'imported') }

      before do
        message_body[:params][:page] = page.slug
        post "/api/pages/#{page.id}/actions", params
      end

      it 'posts action to SQS Queue' do
        expect(sqs_client).to have_received(:send_message).with(expected_queue_payload)
      end
    end

    describe 'country' do
      before do
        params[:country] = 'FR'
        post "/api/pages/#{page.id}/actions", params
      end

      it 'posts full country name to queue' do
        expect(sqs_client).to have_received(:send_message).with(country_field_set_as("France"))
      end
    end

    describe 'referer URI' do
      let(:referer) { 'www.google.com' }

      before do
        post "/api/pages/#{page.id}/actions", params, {referer: referer}
      end

      it 'responds with success' do
        expect(response).to be_success
      end

      it 'includes the referer URI in the queue message' do
        expected_params = {
            queue_url: 'http://example.com',

            message_body: {
                type: 'action',
                params: {
                    page:   "#{page.slug}-petition",
                    email:  "hello@example.com",
                    page_id: page.id.to_s,
                    form_id: form.id.to_s,
                    source: 'fb',
                    akid:   '1234.5678.tKK7gX',
                    referring_akid: '1234.5678.tKK7gX',
                    mobile: 'desktop',
                    referer: referer,
                    user_en: 1,
                }
            }.to_json
        }
        expect(sqs_client).to have_received(:send_message).with(expected_params)
      end
    end

    describe 'mobile detection' do
      let(:referer) { 'www.google.com' }
      let(:en_accept) do
        {
          'HTTP_ACCEPT' => '*/*',
          'HTTP_ACCEPT_LANGUAGE' => 'en',
          'HTTP_ACCEPT_ENCODING' => '*'
        }
      end
      let(:mobile_headers) do
        en_accept.merge('HTTP_USER_AGENT' => 'Mozilla/5.0 (iPad; CPU OS 9_0 like Mac OS X) AppleWebKit/601.1.16 (KHTMLé, like Gecko) Version/8.0 Mobile/13A171a Safari/600.1.4')
      end
      let(:tablet_headers) do
        en_accept.merge('HTTP_USER_AGENT' => 'Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.2; ARM; Trident/6.0; Touch)')
      end
      let(:desktop_headers) do
        en_accept.merge('HTTP_USER_AGENT' => 'Mozilla/5.0 (Windows NT 10.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.135 Safari/537.36 Edge/12.10136')
      end
      let(:ascii_headers) do
        en_accept.merge('HTTP_USER_AGENT' => "#{desktop_headers['HTTP_USER_AGENT']}é".force_encoding(Encoding::ASCII_8BIT))
      end

      let(:message_body) do
        {
          type: 'action',
          params: {
            page:   "#{page.slug}-petition",
            email:  "hello@example.com",
            page_id: page.id.to_s,
            form_id: form.id.to_s,
            source: 'fb',
            akid:   '1234.5678.tKK7gX',
            referring_akid: '1234.5678.tKK7gX',
            mobile: 'desktop',
            referer: referer,
            user_en: 1,
          }
        }
      end

      let(:expected_params) do
        {
          queue_url: 'http://example.com',
          message_body: message_body.to_json
        }
      end


      it 'correctly uses desktop as the default' do
        post "/api/pages/#{page.id}/actions", params, {referer: referer}
        expect(sqs_client).to have_received(:send_message).with(expected_params)
      end

      it 'correctly identifies mobile browsers' do
        message_body[:params][:mobile] = 'mobile'
        post "/api/pages/#{page.id}/actions", params, {referer: referer}.merge(mobile_headers)
        expect(sqs_client).to have_received(:send_message).with(expected_params)
      end

      it 'correctly identifies tablet browsers' do
        # Tablet browsers also show up as mobile in our parsing gem.
        message_body[:params][:mobile] = 'mobile'
        post "/api/pages/#{page.id}/actions", params, {referer: referer}.merge(mobile_headers)
        expect(sqs_client).to have_received(:send_message).with(expected_params)
      end

      it 'correctly identifies desktop browsers' do
        post "/api/pages/#{page.id}/actions", params, {referer: referer}.merge(desktop_headers)
        expect(sqs_client).to have_received(:send_message).with(expected_params)
      end

      it 'can handle ASCII-8BIT headers without error' do
        post "/api/pages/#{page.id}/actions", params, {referer: referer}.merge(ascii_headers)
        expect(sqs_client).to have_received(:send_message).with(expected_params)
      end
    end

    describe 'edge case country names' do
      CountriesExtension::COUNTRIES.each do |code, name|
        it "successfully posts #{name}" do
          params[:country] = code.upcase
          post "/api/pages/#{page.id}/actions", params
          expect(sqs_client).to have_received(:send_message).with(country_field_set_as(name))
        end
      end
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
            Action.where('form_data @> ?', {akid: '1234.5678.tKK7gX'}.to_json).first
          ).to eq(page.actions.first)
        end

        it 'saves actionkit_user_id on member' do
          expect(Member.last.actionkit_user_id).to eq('5678')
        end

        it 'posts action to SQS Queue' do
          expect(sqs_client).to have_received(:send_message).with(expected_queue_payload)
        end
      end

      context 'existing member' do
        let!(:member) { create :member, actionkit_user_id: '7777', email: params[:email]}

        it 'overwrites existing actionkit_user_id' do
          post "/api/pages/#{page.id}/actions", params
          expect(member.reload.actionkit_user_id).to eq '5678'
        end
      end

    end

    describe 'referring akid' do
      before do
        params[:referring_akid] = '1234.5678.tKK7gX'
      end

      it 'posts a referring akid' do
        post "/api/pages/#{page.id}/actions", params
        expect(sqs_client).to have_received(:send_message).with(expected_queue_payload)
      end
    end
  end

  ['long_string_with_underscore', '1234.5678', '2', '?&=', '2..2', '..2'].each do |invalid_akid|
    describe "invalid akid '#{invalid_akid}'" do
      let(:params) do
        {
            email: 'hello@example.com',
            form_id: form.id,
            akid: invalid_akid
        }
      end

      context 'existing member' do

        let!(:member) { create :member, actionkit_user_id: '1234', email: params[:email]}

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
                      akid: invalid_akid,
                      mobile: 'desktop',
                      referer: nil,
                      user_en: 1,
                  }
              }.to_json
          }
          expect(sqs_client).to have_received(:send_message).with(expected_params)
        end
      end
    end
  end
end

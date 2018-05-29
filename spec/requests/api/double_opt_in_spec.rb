# frozen_string_literal: true

require 'rails_helper'

describe 'Double opt-in' do
  describe 'creating an action' do
    let(:page) { create(:page, title: 'Foo Bar', slug: 'foo-bar') }
    let(:form) { create(:form_with_email_and_optional_country) }

    let(:params) do
      {
        email:    'hello@example.com',
        form_id:  form.id,
        source:   'fb',
        country:  'DE',
        name: 'John Doe'
      }
    end

    let(:client) { double }

    let(:pending_action) { PendingAction.last }

    before do
      allow(Aws::SNS::Client).to receive(:new) { client }
      allow(client).to receive(:publish)
    end

    it 'sets email' do
      post "/api/pages/#{page.id}/actions", params: params
      expect(pending_action.email).to eq('hello@example.com')
    end

    it 'increments email count' do
      post "/api/pages/#{page.id}/actions", params: params
      expect(pending_action.email_count).to eq(1)
    end

    it 'triggers sns event' do
      post "/api/pages/#{page.id}/actions", params: params

      expect(client).to have_received(:publish).with(
        hash_including(
          message: /token=#{PendingAction.last.token}/
        )
      )
    end

    it 'sets when email was sent' do
      Timecop.freeze do
        @now = Time.now.utc
        post "/api/pages/#{page.id}/actions", params: params
        expect(pending_action.emailed_at.to_s).to eq(@now.to_s)
      end
    end
  end
end

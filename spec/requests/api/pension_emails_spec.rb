# frozen_string_literal: true

require 'rails_helper'

describe 'Pension Emails', type: :request do
  let(:aws_client) { double(:aws_client, put_item: true) }
  let(:akid) { '25429.9032842.RNP4O4' }

  before do
    allow(ChampaignQueue).to receive(:push)
    allow(Aws::DynamoDB::Client).to receive(:new) { aws_client }
    allow(aws_client).to receive(:put_item) { true }
  end

  describe 'POST#create' do
    let(:page) { create(:page, title: 'Foo Bar', slug: 'foo-bar') }
    let(:registered_email) { create(:registered_email_address) }
    let!(:plugin) { create(:email_pension, page: page, from_email_address: registered_email) }

    let(:params) do
      {
        page_slug: 'foo-bar',
        from_name: "Sender's Name",
        from_email: 'sender@example.com',
        to_name: "Target's Name",
        to_email: 'recipient@example.com',
        body: 'Body text',
        target_name: 'Target name',
        country: 'GB',
        subject: 'Subject',
        akid: akid,
        source: 'fb'
      }
    end

    before do
      post "/api/pages/#{page.id}/pension_emails", params: params
    end

    it 'saves email to dynamodb' do
      expected_options = {
        table_name: 'UserMailing',
        item: {
          MailingId: /foo-bar:\d*/,
          UserId: registered_email.email,
          Body: '<p>Body text</p>',
          Subject: 'Subject',
          ToEmails: ['Target name <recipient@example.com>'],
          FromName: "Sender's Name",
          FromEmail: registered_email.email,
          ReplyTo: ["#{registered_email.name} <#{registered_email.email}>"]
        }
      }

      expect(aws_client).to have_received(:put_item).with(expected_options)
    end

    it 'creates an action and member' do
      expect(Action.count).to eq(1)

      expect(Action.first.member.attributes).to include({
        email: 'sender@example.com',
        first_name: "Sender's",
        last_name: 'Name',
        country: 'GB'
      }.stringify_keys)
    end

    it 'posts action to queue' do
      payload = hash_including(
        type: 'action',
        params: hash_including(page: 'foo-bar-petition',
                               name: "Sender's Name",
                               action_target: 'Target name',
                               source: 'fb',
                               action_target_email: 'recipient@example.com',
                               akid: akid)
      )

      expect(ChampaignQueue).to have_received(:push).with(
        payload,
        group_id: /action:\d+/
      )
    end
  end
end

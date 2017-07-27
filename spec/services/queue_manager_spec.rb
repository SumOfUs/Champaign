# frozen_string_literal: true

require 'rails_helper'

describe QueueManager do
  let(:campaign) { create(:campaign) }
  let(:page) { create(:page, slug: 'i-am-a-slug', title: 'boo', campaign: campaign) }

  let(:expected_params) do
    {
      type: :update_pages,
      params: {
        page_id: page.id,
        name: 'i-am-a-slug',
        title: 'boo',
        language: page.language.actionkit_uri,
        tags: [],
        url: "#{Settings.host}/a/i-am-a-slug",
        hosted_with: '/rest/v1/hostingplatform/2/',
        campaign_id: campaign.id
      }
    }
  end

  context 'with valid job type' do
    context 'update_pages' do
      subject { QueueManager.push(page, job_type: :update_pages) }

      it 'posts to queue' do
        expect(ChampaignQueue).to receive(:push)
          .with(expected_params.merge(donation_uri: 'http://example.com/donation',
                                      petition_uri: 'http://example.com/petition'),
                group_id: "page:#{page.id}")

        subject
      end
    end

    context 'create' do
      subject { QueueManager.push(page, job_type: :create) }

      it 'posts to queue' do
        expect(ChampaignQueue).to receive(:push).with(
          expected_params.merge(type: :create), group_id: "page:#{page.id}"
        )
        subject
      end
    end
  end

  context 'with invalid job tpye' do
    it 'raises argument error' do
      expect { QueueManager.push(page, job_type: :bad) }.to raise_error(ArgumentError)
    end
  end
end

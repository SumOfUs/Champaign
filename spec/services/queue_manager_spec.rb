require 'rails_helper'

describe QueueManager do
  let(:page) { create(:page, slug: 'i-am-a-slug', title: 'boo') }

  let(:expected_params) do
    {
      type: :update_pages,
      params: {
        page_id: page.id,
        name: 'i-am-a-slug',
        title: 'boo',
        language: nil,
        tags: []
      }
    }
  end

  context "with valid job type" do
    context "update_pages" do

      subject { QueueManager.push(page, job_type: :update_pages) }

      it 'posts to queue' do
        expect(ChampaignQueue).to receive(:push).
          with( expected_params.merge({
            donation_uri: "http://example.com/donation",
            petition_uri: "http://example.com/petition"
          }))

        subject
      end
    end

    context "create" do
      subject { QueueManager.push(page, job_type: :create) }

      it 'posts to queue' do
        expect(ChampaignQueue).to receive(:push).with( expected_params.merge(type: :create) )
        subject
      end
    end
  end

  context "with invalid job tpye" do
    it 'raises argument error' do
      expect{ QueueManager.push(page, job_type: :bad) }.to raise_error(ArgumentError)
    end
  end
end


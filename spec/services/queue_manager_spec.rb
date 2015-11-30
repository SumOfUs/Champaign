require 'rails_helper'

describe QueueManager do
  let(:page) { create(:page, slug: 'i-am-a-slug', title: 'boo') }

  let(:expected_params) do
    {
      type: :update,
      params: {
        id: page.id,
        slug: 'i-am-a-slug',
        title: 'boo',
        language_code: 'en',
        tags: []
      }
    }
  end

  context "with valid job type" do
    context "update" do

      subject { QueueManager.push(page, job_type: :update) }

      it 'posts to queue' do
        expected_params_donation = expected_params.merge(uri: "http://example.com/donation")
        expected_params_petition = expected_params.merge(uri: "http://example.com/petition")

        expect(ChampaignQueue).to receive(:push).with( expected_params_petition )
        expect(ChampaignQueue).to receive(:push).with( expected_params_donation )

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


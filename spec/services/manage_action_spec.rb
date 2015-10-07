require 'rails_helper'

describe ManageAction do
  before do
    allow(ChampaignQueue).to receive(:push)
  end

  let(:page) { create(:page) }
  let(:data) { { email: 'bob@example.com', page_id: page.id } }

  before do
    allow(ChampaignQueue).to receive(:push)
  end

  describe '#create' do
    subject { ManageAction.create(data) }

    it 'creates an action' do
      expect(subject).to be_a Action
    end

    it 'posts action to queue' do
      expect(ChampaignQueue).to receive(:push).
        with({
        type: "action", params: {
          slug: page.slug,
          email: "bob@example.com",
          page_id: page.id }
      })

      subject
    end

    it 'creates an action user' do
      expect(subject.action_user.email).to eq('bob@example.com')
    end

    it 'uses existing user if present' do
      create(:action_user, email: 'bob@example.com')

      expect{ subject }.to_not change{ ActionUser.count }.from(1)
    end

    context "action already exists" do
      before do
        @action = ManageAction.create(data)
      end

      it 'returns false' do
        expect(subject).to be false
      end

      it 'does not post to queue' do
        expect(ChampaignQueue).to_not receive(:push)

        subject
      end
    end
  end
end


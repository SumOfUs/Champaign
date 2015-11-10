require 'rails_helper'

describe ManageAction do
  before do
    allow(ChampaignQueue).to receive(:push)
  end

  let(:page) { create(:page) }
  let(:data) { { email: 'bob@example.com', page_id: page.id } }
  let(:first_name) { { first_name: 'Bobtholomew' } }
  let(:extraneous) { { is_delta_shareholder: true, eye_color: 'hazel' } }

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
          body: {
            email: "bob@example.com",
            page_id: page.id
          }
        }
      })

      subject
    end

    describe 'new action_user' do
      it 'creates an action user' do
        expect{ subject }.to change{ ActionUser.count }.by 1
      end
      
      it 'saves available fields to action_user' do
        action = ManageAction.create(data.merge(first_name))
        expect(action.action_user.first_name).to eq first_name[:first_name]
        expect(action.action_user.email).to eq data[:email]
        persisted = action.action_user.reload
        expect(persisted.first_name).to eq first_name[:first_name]
        expect(persisted.email).to eq data[:email]
      end

      it 'creates an action user even with extraneous fields' do
        expect{
          ManageAction.create(data.merge(extraneous) )
        }.to change{ ActionUser.count }.by 1
      end

      it 'saves available fields even with extraneous fields' do
        action = ManageAction.create(data.merge(first_name).merge(extraneous) )
        expect(action.action_user.reload.first_name).to eq first_name[:first_name]
        expect(action.action_user.reload.email).to eq data[:email]
      end
    end

    describe 'existing action_user' do

      before :each do
        @existing = create :action_user, email: data[:email]
      end

      it 'does not change the number of action users' do
        expect{ subject }.to_not change{ ActionUser.count }.from(1)
      end

      it 'saves all new fields to action_user' do
        action = ManageAction.create(data.merge(first_name).merge(email: 'new@email.com'))
        expect(action.action_user.first_name).to eq first_name[:first_name]
        expect(action.action_user.email).to eq 'new@email.com'
        persisted = action.action_user.reload
        expect(persisted.first_name).to eq first_name[:first_name]
        expect(persisted.email).to eq 'new@email.com'
      end

      it 'is not bothered by fields not saveable to action_user' do
        action = ManageAction.create(data.merge(first_name).merge(extraneous))
        expect(action.action_user.first_name).to eq first_name[:first_name]
        expect(action.action_user.reload.first_name).to eq first_name[:first_name]
      end

      it 'does not touch existing fields if not included' do
        @existing.update_attributes(first_name: 'Bupkis')
        action = ManageAction.create(data.merge(last_name: 'McBamgler'))
        expect(action.action_user.first_name).to eq 'Bupkis'
        expect(action.action_user.reload.first_name).to eq 'Bupkis'
      end

      it 'does not overwrite existing fields with nil' do
        @existing.update_attributes(first_name: 'Bupkis')
        action = ManageAction.create(data.merge(first_name: nil))
        expect(action.action_user.first_name).to eq 'Bupkis'
        expect(action.action_user.reload.first_name).to eq 'Bupkis'
      end
    end

    context "action already exists" do
      before do
        @action = ManageAction.create(data)
      end

      it 'returns existing action' do
        expect(subject).to eq @action
      end

      it 'does not post to queue' do
        expect(ChampaignQueue).to_not receive(:push)

        subject
      end
    end
  end
end


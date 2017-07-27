# frozen_string_literal: true

require 'rails_helper'

describe ManageAction do
  before do
    allow(ChampaignQueue).to receive(:push)
    allow(Analytics::Page).to receive(:increment)
  end

  let(:page) { create(:page, title: 'Foo Bar') }
  let(:data) { { email: 'bob@example.com', page_id: page.id, referring_akid: '123.456.xyz' } }
  let(:first_name) { { first_name: 'Bobtholomew' } }
  let(:extraneous) { { is_delta_shareholder: true, eye_color: 'hazel' } }

  before do
    allow(ChampaignQueue).to receive(:push)
  end

  describe '.create' do
    subject { ManageAction.create(data) }

    it 'creates an action' do
      expect(subject).to be_a Action
    end

    it 'posts action to queue' do
      payload = {
        type: 'action',
        meta: hash_including(
          title: 'Foo Bar'
        ),
        params: {
          page:           "#{page.slug}-petition",
          email:          'bob@example.com',
          page_id:        page.id,
          referring_akid: '123.456.xyz',
          user_en: 1
        }
      }

      expect(ChampaignQueue).to receive(:push)
        .with(payload, group_id: /action:\d+/)
      subject
    end

    describe 'new member' do
      it 'creates an member' do
        expect { subject }.to change { Member.count }.by 1
      end

      it 'saves available fields to member' do
        action = ManageAction.create(data.merge(first_name))
        expect(action.member.first_name).to eq first_name[:first_name]
        expect(action.member.email).to eq data[:email]
        persisted = action.member.reload
        expect(persisted.first_name).to eq first_name[:first_name]
        expect(persisted.email).to eq data[:email]
      end

      it 'creates an member even with extraneous fields' do
        expect do
          ManageAction.create(data.merge(extraneous))
        end.to change { Member.count }.by 1
      end

      it 'saves available fields even with extraneous fields' do
        action = ManageAction.create(data.merge(first_name).merge(extraneous))
        expect(action.member.reload.first_name).to eq first_name[:first_name]
        expect(action.member.reload.email).to eq data[:email]
      end

      it 'ignores a sent id parameter' do
        action = ManageAction.create(data.merge(id: 200))
        expect(action.id).not_to eq 200
      end
    end

    describe 'existing member' do
      before :each do
        @existing = create :member, email: data[:email]
      end

      it 'does not change the number of members' do
        expect { subject }.to_not change { Member.count }.from(1)
      end

      it 'saves all new fields to member' do
        action = ManageAction.create(data.merge(first_name))
        expect(action.member.first_name).to eq first_name[:first_name]
        expect(action.member.reload.first_name).to eq first_name[:first_name]
        expect(action.member).to eq @existing.reload
      end

      it 'is not bothered by fields not saveable to member' do
        action = ManageAction.create(data.merge(first_name).merge(extraneous))
        expect(action.member.first_name).to eq first_name[:first_name]
        expect(action.member.reload.first_name).to eq first_name[:first_name]
      end

      it 'does not touch existing fields if not included' do
        @existing.update_attributes(first_name: 'Bupkis')
        action = ManageAction.create(data.merge(last_name: 'McBamgler'))
        expect(action.member.first_name).to eq 'Bupkis'
        expect(action.member.reload.first_name).to eq 'Bupkis'
      end

      it 'does not overwrite existing fields with nil' do
        @existing.update_attributes(first_name: 'Bupkis')
        action = ManageAction.create(data.merge(first_name: nil))
        expect(action.member.first_name).to eq 'Bupkis'
        expect(action.member.reload.first_name).to eq 'Bupkis'
      end

      it 'does not create an Member if sent an id parameter' do
        expect { ManageAction.create(data.merge(id: 200)) }.not_to change { Member.count }
      end

      it 'ignores a sent id parameter' do
        action = ManageAction.create(data.merge(id: 200))
        expect(action.member.id).to eq @existing.reload.id
        expect(action.member.id).not_to eq 200
      end
    end

    context 'action already exists' do
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

    context 'page permits duplicate actions' do
      before do
        page.update(allow_duplicate_actions: true)
        @action = ManageAction.create(data)
      end

      it 'returns new action' do
        expect(subject).not_to eq @action
        expect(subject).to be_an(Action)
      end

      it 'posts to queue' do
        expect(ChampaignQueue).to receive(:push)

        subject
      end
    end
  end
end

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
        expect(Action).to receive(:create!)
          .with(hash_excluding(id: 200))
          .and_call_original

        ManageAction.create(data.merge(id: 200))
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

    describe 'consent' do
      let(:extra_params) { {} }

      shared_examples 'regular action creation' do
        it 'creates an action' do
          expect {
            ManageAction.create(params, extra_params: extra_params)
          }.to change(Action, :count).by(1)
        end

        it 'creates a member' do
          action = nil
          expect {
            action = ManageAction.create(params, extra_params: extra_params)
          }.to change(Member, :count).by(1)

          expect(action.member.email).to eq params[:email]
        end

        it 'publishes an event' do
          expect(ChampaignQueue).to receive(:push)
          ManageAction.create(params, extra_params: extra_params)
        end
      end

      context 'for an existing member' do
        let!(:member) { create(:member, email: 'bob@example.com') }
        let(:params) { { email: 'bob@example.com', first_name: 'Bob', page_id: page.id } }

        context 'that gives consent' do
          before { params[:consented] = true }

          it 'creates an action' do
            expect {
              ManageAction.create(params)
            }.to change(Action, :count).by(1)
          end

          it 'updates the member' do
            ManageAction.create(params)
            expect(member.reload.first_name).to eq('Bob')
            expect(member.consented).to be true
          end

          it 'publishes an event' do
            expect(ChampaignQueue).to receive(:push)
            ManageAction.create(params)
          end
        end

        context "that explicitly doesn't give consent" do
          before { params[:consented] = false }

          it 'creates an action' do
            action = nil
            expect {
              action = ManageAction.create(params)
            }.to change(Action, :count).by(1)
          end

          it 'updates the member' do
            ManageAction.create(params)
            expect(member.reload.first_name).to eq('Bob')
            expect(member.consented).to be false
          end

          it 'publishes an event' do
            expect(ChampaignQueue).to receive(:push)
            ManageAction.create(params)
          end
        end
      end

      context 'for a new user' do
        describe 'given a EEA country is selected and the action is not a donation' do
          let(:params) { { email: 'bob@example.com', name: 'Bob', country: 'DE', page_id: page.id } }

          context 'that gives consent' do
            before { params[:consented] = true }
            include_examples 'regular action creation'

            it 'updates the consented flag on the member' do
              action = ManageAction.create(params)
              expect(action.member.consented).to be true
            end
          end

          context "that doesn't give consent" do
            before { params[:consented] = false }
            it "creates an action, only saving the user's name" do
              action = nil
              expect {
                action = ManageAction.create(params)
              }.to change(Action, :count).by(1)
              expect(action.form_data).to eq('name' => 'Bob')
            end

            it "doesn't create a member" do
              action = nil
              expect {
                action = ManageAction.create(params)
              }.not_to change(Member, :count)
              expect(action.member).to be_nil
            end

            it "doesn't publish an event" do
              expect(ChampaignQueue).not_to receive(:push)
              ManageAction.create(params)
            end
          end
        end

        context 'given a non EEA country is selected and no consent is given' do
          let(:params) { { email: 'bob@example.com', country: 'AR', page_id: page.id } }

          include_examples 'regular action creation'
        end

        context 'given it is a donation action and no consent is given' do
          let(:params) { { email: 'bob@example.com', country: 'DE', page_id: page.id } }
          let(:extra_params) { { donation: true } }

          include_examples 'regular action creation'
        end
      end
    end
  end
end

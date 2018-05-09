# frozen_string_literal: true

require 'rails_helper'

describe Api::ActionsController do
  describe 'POST create' do
    let(:form) { instance_double('Form', form_elements: [double(name: 'foo')]) }
    let(:page) { instance_double('Page', id: 2) }
    let(:member) { instance_double('Member', id: 12) }
    let(:action) { instance_double('Action', member_id: member.id, member: member) }
    let(:follower) { instance_double('PageFollower', follow_up_path: '/asdf?member_id=12345') }

    before :each do
      allow(Form).to receive(:find) { form }
      allow(Page).to receive(:find) { page }
      allow(PageFollower).to receive(:new_from_page) { follower }
      allow(ManageAction).to receive(:create) { action }
      allow(controller).to receive(:localize_from_page_id)
    end

    let(:validator) { instance_double('FormValidator', valid?: true, errors: []) }

    before do
      allow(FormValidator).to receive(:new) { validator }
    end

    describe 'successful' do
      before do
        allow(controller).to receive(:verify_authenticity_token)
        post :create, params: { page_id: 2, form_id: 3, foo: 'bar' }
      end

      it 'does not verify authenticity token' do
        expect(controller).not_to have_received(:verify_authenticity_token)
      end

      it 'finds form' do
        expect(Form).to have_received(:find).with('3')
      end

      it 'delegates to Action with params' do
        expected_params = { foo: 'bar', page_id: '2', form_id: '3', action_mobile: 'desktop', action_referer: nil }.stringify_keys

        expect(ManageAction).to have_received(:create)
          .with(expected_params)
      end

      it 'responds with an empty hash' do
        expect(response.body).to eq({ follow_up_url: '/asdf?member_id=12345' }.to_json)
      end

      it 'sets the cookie' do
        expect(cookies.signed['member_id']).to eq member.id
      end

      it 'attemptes to localize the page' do
        expect(controller).to have_received(:localize_from_page_id)
      end
    end

    describe 'filtering' do
      it 'does not permit params not in the form' do
        expect do
          post :create, params: { page_id: 2, form_id: 3, not_permitted: 'no, no!', foo: 'bar' }
        end.to raise_error(
          ActionController::UnpermittedParameters,
          'found unpermitted parameter: :not_permitted'
        )
      end
    end

    describe 'URL params' do
      before do
        post :create, params: { page_id: 2, form_id: 3, foo: 'bar', source: 'FB', akid: '123.456.rfs' }
      end

      it 'takes source' do
        expect(ManageAction).to have_received(:create)
          .with(hash_including(source: 'FB'))
      end

      it 'takes akid' do
        expect(ManageAction).to have_received(:create)
          .with(hash_including(akid: '123.456.rfs'))
      end
    end

    describe 'unsuccessful' do
      let(:validator) { instance_double('FormValidator', valid?: false, errors: [['my field', 'my error']]) }

      before :each do
        allow(FormValidator).to receive(:new) { validator }
        post :create, params: { page_id: 2, form_id: 3, foo: 'bar' }
      end

      it 'does not create an action' do
        expect(ManageAction).not_to have_received(:create)
      end

      it 'displays the errors' do
        expect(validator).to have_received(:errors)
      end

      it 'does not set the cookie' do
        expect(cookies.signed['member_id']).to eq nil
        expect(response.cookies[:member_id]).to eq nil
      end
    end
  end

  describe 'POST validate' do
    let(:form) { instance_double('Form', form_elements: [double(name: 'foo')]) }

    before :each do
      allow(Form).to receive(:find) { form }
      allow(ManageAction).to receive(:create)
      allow(controller).to receive(:localize_from_page_id)
    end

    describe 'successful' do
      let(:validator) { instance_double('FormValidator', valid?: true, errors: []) }

      before do
        allow(FormValidator).to receive(:new) { validator }
        post :validate, params: { page_id: 2, form_id: 3, foo: 'bar' }
      end

      it 'finds form' do
        expect(Form).to have_received(:find).with('3')
      end

      it 'checkes validity' do
        expect(validator).to have_received(:valid?)
      end

      it 'does not create an action' do
        expect(ManageAction).not_to have_received(:create)
      end

      it 'responds with empty json' do
        expect(response.body).to eq({}.to_json)
      end

      it 'does not set the cookie' do
        expect(cookies.signed['member_id']).to eq nil
        expect(response.cookies[:member_id]).to eq nil
      end

      it 'attemptes to localize the page' do
        expect(controller).to have_received(:localize_from_page_id)
      end
    end

    describe 'filtering' do
      it 'does not permit params not in the form' do
        expect {
          post :validate, params: { page_id: 2, form_id: 3, not_permitted: 'no, no!', foo: 'bar' }
        }.to raise_error(
          ActionController::UnpermittedParameters,
          'found unpermitted parameter: :not_permitted'
        )
      end
    end

    describe 'unsuccessful' do
      let(:validator) { instance_double('FormValidator', valid?: false, errors: [['my field', 'my error']]) }

      before :each do
        allow(FormValidator).to receive(:new) { validator }
        post :validate, params: { page_id: 2, form_id: 3, foo: 'bar' }
      end

      it 'does not create an action' do
        expect(ManageAction).not_to have_received(:create)
      end

      it 'displays the errors' do
        expect(validator).to have_received(:errors)
      end

      it 'does not set the cookie' do
        expect(cookies.signed['member_id']).to eq nil
        expect(response.cookies[:member_id]).to eq nil
      end
    end
  end

  describe 'PUT update' do
    let!(:a) { create :action }

    describe 'successful' do
      it 'returns 200' do
        put :update, params: { page_id: 2, id: a.id, publish_status: 'published' }
        expect(response).to be_success
      end

      it 'changes the status to published' do
        expect {
          put :update, params: { page_id: 2, id: a.id, publish_status: 'published' }
        }.to change {
          a.reload.publish_status
        }.from('default').to('published')
      end

      it 'changes the status to hidden' do
        expect {
          put :update, params: { page_id: 2, id: a.id, publish_status: 'hidden' }
        }.to change {
          a.reload.publish_status
        }.from('default').to('hidden')
      end

      it 'changes the status to default' do
        a.published!
        expect {
          put :update, params: { page_id: 2, id: a.id, publish_status: 'default' }
        }.to change {
          a.reload.publish_status
        }.from('published').to('default')
      end
    end

    describe 'unsuccessful' do
      let!(:a) { create :action }

      it 'raises not found if no action is found with that id' do
        expect {
          put :update, params: { page_id: 2, id: 9999, publish_status: 'default' }
        }.to raise_error ActiveRecord::RecordNotFound
      end

      it 'returns errors and 422 if given an invalid publish_status' do
        put :update, params: { page_id: 2, id: a.id, publish_status: 'invalid' }
        expect(response.code).to eq '422'
        expect(response.body).to eq '{"errors":{"publish_status":"\'invalid\' is not a valid publish_status"}}'
      end

      it 'does not update the action when given an invalid publish_status' do
        expect {
          put :update, params: { page_id: 2, id: a.id, publish_status: 'invalid' }
        }.not_to(change {
          a.reload.publish_status
        })
      end
    end
  end
end

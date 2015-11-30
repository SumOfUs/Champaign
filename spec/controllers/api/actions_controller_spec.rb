require 'rails_helper'

describe Api::ActionsController do

  describe "POST create" do
    let(:form) { instance_double('Form', form_elements: [double(name: 'foo')] ) }
    let(:member) { instance_double('Member', id: 12) }
    let(:action) { instance_double('Action', member: member)}

    before :each do
      allow(Form).to receive(:find){ form }
      allow(ManageAction).to receive(:create){ action }
    end

    describe "successful" do

      let(:validator) { instance_double('FormValidator', valid?: true, errors: []) }

      before do
        allow(FormValidator).to receive(:new){ validator }
        post :create, { page_id: 2, form_id: 3, foo: 'bar' }
      end

      it "finds form" do
        expect(Form).to have_received(:find).with('3')
      end

      it "delegates to Action with params" do
        expected_params = { page_id: '2', form_id: '3', foo: 'bar'}.stringify_keys

        expect(ManageAction).to have_received(:create).
          with(expected_params)
      end

      it "filters params by those present in the form" do
        expect {
          post :create, { page_id: 2, form_id: 3, not_permitted: 'no, no!' }
        }.to raise_error(
          ActionController::UnpermittedParameters,
          "found unpermitted parameter: not_permitted"
        )
      end

      it "responds with the follow-up url" do
        expect(response.body).to eq({ follow_up_url: follow_up_page_path(2) }.to_json)
      end

      it 'sets the cookie' do
        expect(cookies.signed['member_id']).to eq member.id
      end
    end

    describe "unsuccessful" do

      let(:validator) { instance_double('FormValidator', valid?: false, errors: [["my field", "my error"]]) }

      before :each do
        allow(FormValidator).to receive(:new){ validator }
        post :create, { page_id: 2, form_id: 3, foo: 'bar' }
      end

      it "does not create an action" do
        expect(ManageAction).not_to have_received(:create)
      end

      it "displays the errors" do
        expect(validator).to have_received(:errors)
      end

      it 'does not set the cookie' do
        expect(cookies.signed['member_id']).to eq nil
        expect(response.cookies[:member_id]).to eq nil
      end
    end
  end

  describe 'POST validate' do
    let(:form) { instance_double('Form', form_elements: [double(name: 'foo')] ) }

    before :each do
      allow(Form).to receive(:find){ form }
      allow(ManageAction).to receive(:create)
    end

    describe "successful" do

      let(:validator) { instance_double('FormValidator', valid?: true, errors: []) }

      before do
        allow(FormValidator).to receive(:new){ validator }
        post :validate, { page_id: 2, form_id: 3, foo: 'bar' }
      end

      it "finds form" do
        expect(Form).to have_received(:find).with('3')
      end

      it 'checkes validity' do
        expect(validator).to have_received(:valid?)
      end

      it "does not create an action" do
        expect(ManageAction).not_to have_received(:create)
      end

      it "filters params by those present in the form" do
        expect {
          post :validate, { page_id: 2, form_id: 3, not_permitted: 'no, no!' }
        }.to raise_error(
          ActionController::UnpermittedParameters,
          "found unpermitted parameter: not_permitted"
        )
      end

      it "responds with empty json" do
        expect(response.body).to eq({}.to_json)
      end

      it 'does not set a cookie the cookie' do
        expect(cookies.signed['action_user_id']).to eq nil
        expect(response.cookies[:action_user_id]).to eq nil
      end
    end

    describe "unsuccessful" do

      let(:validator) { instance_double('FormValidator', valid?: false, errors: [["my field", "my error"]]) }

      before :each do
        allow(FormValidator).to receive(:new){ validator }
        post :validate, { page_id: 2, form_id: 3, foo: 'bar' }
      end

      it "does not create an action" do
        expect(ManageAction).not_to have_received(:create)
      end

      it "displays the errors" do
        expect(validator).to have_received(:errors)
      end

      it 'does not set the cookie' do
        expect(cookies.signed['action_user_id']).to eq nil
        expect(response.cookies[:action_user_id]).to eq nil
      end
    end
  end
end

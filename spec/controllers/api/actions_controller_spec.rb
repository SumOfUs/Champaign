require 'rails_helper'

describe Api::ActionsController do

  describe "POST create" do
    let(:form) { instance_double('Form', form_elements: [double(name: 'foo')] ) }

    before :each do
      allow(Form).to receive(:find){ form }
      allow(Action).to receive(:create_action)
    end

    describe "successful" do

      let(:validator) { instance_double('FormValidator', valid?: true, errors: []) }

      before do
        allow(FormValidator).to receive(:new){ validator }
        post :create, { campaign_page_id: 2, form_id: 3, foo: 'bar' }
      end

      it "finds form" do
        # once for each call to action_params, once for validator
        expect(Form).to have_received(:find).twice.with('3')
      end

      it "delegates to Action with params" do
        expected_params = { campaign_page_id: '2', form_id: '3', foo: 'bar'}.stringify_keys

        expect(Action).to have_received(:create_action).
          with(expected_params)
      end

      it "filters params by those present in the form" do
        expect {
          post :create, { campaign_page_id: 2, form_id: 3, not_permitted: 'no, no!' }
        }.to raise_error(
          ActionController::UnpermittedParameters,
          "found unpermitted parameter: not_permitted"
        )
      end
    end

    describe "unsuccessful" do

      let(:validator) { instance_double('FormValidator', valid?: false, errors: [["my field", "my error"]]) }

      before :each do
        allow(FormValidator).to receive(:new){ validator }
        post :create, { campaign_page_id: 2, form_id: 3, foo: 'bar' }
      end

      it "does not create an action" do
        expect(Action).not_to have_received(:create_action)
      end

      it "displays the errors" do
        expect(validator).to have_received(:errors)
      end
    end
  end
end

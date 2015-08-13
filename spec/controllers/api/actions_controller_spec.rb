require 'rails_helper'

describe Api::ActionsController do

  describe "POST create" do
    let(:form) { instance_double('Form', form_elements: [double(name: 'foo')] ) }

    before do
      allow(Action).to receive(:create_action)
      allow(Form).to receive(:find){ form }
      post :create, { campaign_page_id: 2, form_id: 3, foo: 'bar' }
    end

    it "finds form" do
      expect(Form).to have_received(:find).with('3')
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
end

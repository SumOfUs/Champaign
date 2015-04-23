require 'rails_helper'
require 'spec_helper'

describe ActionkitPageTypeParameters do
  describe ".permit" do
    
    describe "when permitted parameters" do
      it 'should permit actionkit_page_type' do
        page_params = { actionkit_page_type: "test" }
        params = ActionController::Parameters.new(actionkit_page_type: page_params)
        permitted_params = ActionkitPageTypeParameters.new(params).permit
        expect(permitted_params).to eq page_params.with_indifferent_access
      end
    end

    describe "when unpermitted parameters" do
      it "raises error" do
        page_params = { foo: "bar" }
        params = ActionController::Parameters.new(actionkit_page_type: page_params)
        expect{ ActionkitPageTypeParameters.new(params).permit }.
          to raise_error(ActionController::UnpermittedParameters)
      end
    end
  end
end
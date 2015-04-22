require 'rails_helper'
require 'spec_helper'

RSpec.describe ActionKitPageTypeParameter do
  it 'should permit actionkit_page_type' do
    params = ActionController::Parameters.new actionkit_page_type:
                                                  {actionkit_page_type: 'test'}
    p params.object_id

    permitted_params = ActionKitPageTypeParameter.new(params: params).permit

    expect(permitted_params).to eq params.with_indifferent_access
  end
end
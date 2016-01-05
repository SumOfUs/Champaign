require 'rails_helper'

describe DefaultFormBuilder do
  it 'creates a default master form' do
    expect{
      DefaultFormBuilder.create
    }.to change{ Form.count }.from(0).to(1)
  end

  it 'creates fields' do
    expect( DefaultFormBuilder.create.form_elements.size ).to eq(3)
  end

  context 'when form already exists' do
    before {  DefaultFormBuilder.create  }

    it 'returns form' do
      expect {
         DefaultFormBuilder.create
      }.to_not change{ Form.count }
    end
  end
end


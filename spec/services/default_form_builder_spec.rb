require 'rails_helper'

describe DefaultFormBuilder do
  it 'creates a default master form' do
    expect{
      DefaultFormBuilder.create
    }.to change{ Form.count }.from(0).to(1)
  end

  it 'creates fields' do
    expect( DefaultFormBuilder.create.form_elements.size ).to eq(4)
  end

  context 'when form already exists' do
    before {  DefaultFormBuilder.create  }

    it "doesn't create a new form" do
      expect {
         DefaultFormBuilder.create
      }.to_not change{ Form.count }.from(1)
    end

    it 'returns existing form' do
      expect( DefaultFormBuilder.create.name).to eq('Basic')
    end
  end
end


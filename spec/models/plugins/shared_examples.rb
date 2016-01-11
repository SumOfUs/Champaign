shared_examples "plugin with form" do

  let(:form) { create :form_with_email }

  it 'has a default form' do
    expect(subject.form.name).to eq('Basic')
    expect(subject.form.master?).to be false
  end

  it "can accept random supplemental data to liquid_data method" do
    expect{ subject.liquid_data({foo: 'bar'}) }.not_to raise_error
  end

  it "serializes outstanding_fields without a form or values" do
    subject.form = nil
    expect( subject.liquid_data[:outstanding_fields]).to eq []
  end

  it "serializes outstanding_fields without a form but with values" do
    subject.form = nil
    expect( subject.liquid_data({form_values: {email: 'a'}})[:outstanding_fields]).to eq []
  end

  it "serializes outstanding_fields without values but with a form" do
    subject.form = form
    subject.form.form_elements.each{ |el| el.update_attributes(required: true) }
    expect( subject.liquid_data[:outstanding_fields]).to eq ['email']
  end

  it "serializes outstanding_fields with a form and values" do
    subject.form = form
    expect( subject.liquid_data({form_values: {email: 'a'}})[:outstanding_fields]).to eq ['email']
  end

  it "serializes outstanding_fields with a form and values that match" do
    subject.form = form
    expect( subject.liquid_data({form_values: {email: 'neal@test.com'}})[:outstanding_fields]).to eq []
  end
end


shared_examples "plugin with form" do |plugin_sym|

  let(:plugin) { create plugin_sym }
  let(:form) { create :form_with_email }

  it "can accept random supplemental data to liquid_data method" do
    expect{ plugin.liquid_data({foo: 'bar'}) }.not_to raise_error
  end

  it "serializes outstanding_fields without a form or values" do
    plugin.form_id = nil
    expect( plugin.liquid_data[:outstanding_fields]).to eq []
  end

  it "serializes outstanding_fields without a form but with values" do
    plugin.form_id = nil
    expect( plugin.liquid_data({form_values: {email: 'a'}})[:outstanding_fields]).to eq []
  end

  it "serializes outstanding_fields without values but with a form" do
    plugin.form_id = form.id
    plugin.form.form_elements.each{ |el| el.update_attributes(required: true) }
    expect( plugin.liquid_data[:outstanding_fields]).to eq ['email']
  end

  it "serializes outstanding_fields with a form and values" do
    plugin.form_id = form.id
    expect( plugin.liquid_data({form_values: {email: 'a'}})[:outstanding_fields]).to eq ['email']
  end

  it "serializes outstanding_fields with a form and values that match" do
    plugin.form_id = form.id
    expect( plugin.liquid_data({form_values: {email: 'neal@test.com'}})[:outstanding_fields]).to eq []
  end

end
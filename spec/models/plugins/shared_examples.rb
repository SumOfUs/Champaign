shared_examples "plugin with form" do |plugin_type|

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

  it 'deletes the form when it is deleted' do
    subject.form = form
    subject.save!
    expect{ subject.destroy! }.not_to raise_error
    expect{ form.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end

  it 'auto-creates a master form and current form with default fields' do
    # it creates two forms cause it creates the master form if it doesn't exist
    expect{ @p = create plugin_type }.to change{ Form.count }.by 2
    expect( @p.form.form_elements.map(&:name)).to match_array(['email','name','country','postal'])
    expect(Form.all.map(&:master)).to match_array([true, false])

    # now master already exists, just makes one form
    expect{ create plugin_type }.to change{ Form.count }.by 1
  end

  it 'will not auto-override the form passed to the factory' do
    my_form = create :form_with_email_and_name
    expect{ @p = create plugin_type, form: my_form }.to change{ Form.count }.by 0
    expect( @p.form.form_elements.map(&:name)).to match_array(['email', 'name'])
  end

  describe '#update_form' do
    let!(:new_form) { create(:form, master: false) }

    it 'updates form' do
      subject.update_form(new_form)
      expect(subject.reload.form).to eq(new_form)
    end

    it 'deletes original form' do
      old_form = subject.form

      subject.update_form(new_form)

      expect{
        old_form.reload
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end


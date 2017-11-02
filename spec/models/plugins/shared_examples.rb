# frozen_string_literal: true

shared_examples 'plugin with form' do |plugin_type|
  let(:form) { create :form_with_email }

  it 'has a default form' do
    expect(subject.form.name).to eq('Basic (EN)')
    expect(subject.form.master?).to be false
  end

  it 'translates default form if page has a language' do
    german = create(:language, code: 'de')
    page = create(:page, language: german)
    plugin = create plugin_type, page: page
    expect(plugin.form.name).to eq 'Basic (DE)'
  end

  it 'can accept random supplemental data to liquid_data method' do
    expect { subject.liquid_data(foo: 'bar') }.not_to raise_error
  end

  it 'serializes outstanding_fields without a form or values' do
    subject.form = nil
    expect(subject.liquid_data[:outstanding_fields]).to eq []
  end

  it 'serializes outstanding_fields without a form but with values' do
    subject.form = nil
    expect(subject.liquid_data(form_values: { email: 'a' })[:outstanding_fields]).to eq []
  end

  it 'serializes outstanding_fields without values but with a form' do
    subject.form = form
    subject.form.form_elements.each { |el| el.update_attributes(required: true) }
    expect(subject.liquid_data[:outstanding_fields]).to eq ['email']
  end

  it 'serializes outstanding_fields with a form and values' do
    subject.form = form
    expect(subject.liquid_data(form_values: { email: 'a' })[:outstanding_fields]).to eq ['email']
  end

  it 'serializes outstanding_fields with a form and values that match' do
    subject.form = form
    expect(subject.liquid_data(form_values: { email: 'neal@test.com' })[:outstanding_fields]).to eq []
  end

  it 'deletes the form when it is deleted' do
    subject.form = form
    subject.save!
    expect { subject.destroy! }.not_to raise_error
    expect { form.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end

  it 'auto-creates a master form and current form with default fields' do
    # it creates two forms cause it creates the master form if it doesn't exist
    expect { @p = create plugin_type }.to change { Form.count }.by 2
    expect(@p.form.form_elements.map(&:name)).to match_array(%w[email name country postal action_phone_number])
    expect(Form.all.map(&:master)).to match_array([true, false])

    # now master already exists, just makes one form
    expect { create plugin_type }.to change { Form.count }.by 1
  end

  it 'will not auto-override the form passed to the factory' do
    my_form = create :form_with_email_and_name
    expect { @p = create plugin_type, form: my_form }.to change { Form.count }.by 0
    expect(@p.form.form_elements.map(&:name)).to match_array(%w[email name])
  end

  describe '#update_form' do
    let!(:new_form) { create(:form, master: false) }

    it 'updates form' do
      subject.update_form(new_form)
      expect(subject.reload.form).to eq(new_form)
    end

    it 'deletes original form' do
      old_form = subject.form
      expect do
        subject.update_form(new_form)
      end.to change { Form.count }.by -1

      expect do
        old_form.reload
      end.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "deletes the original form's form_elements" do
      el_count = subject.form.form_elements.size
      expect(el_count).to be > 0
      expect { subject.update_form(new_form) }.to change { FormElement.count }.by(-el_count)
    end

    it 'does nothing if new_form is nil' do
      old_form = subject.form
      expect { subject.update_form(nil) }.not_to change { Form.count }
      expect(subject.form).to eq old_form
    end
  end
end

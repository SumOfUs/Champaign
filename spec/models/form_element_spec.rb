require 'rails_helper'

describe FormElement do
  let(:form)    { create(:form) }
  let(:element) { create(:form_element, form: form) }

  it 'belongs to a form' do
    el = create(:form_element)
    expect(el.form).to be_a Form
  end

  describe '.create' do
    it 'sets position' do
      element_0 = create(:form_element, form: form)
      element_1 = create(:form_element, form: form)

      expect(element_0.position).to eq(0)
      expect(element_1.position).to eq(1)
    end

    it 'sets name' do
      expect( create(:form_element, label: 'Email').name ).to eq('email')
    end
  end

  describe '.update' do
    it 'does not change position' do
      expect{
        element.update(label: "Surname")
      }.to_not change{ element.reload.position}
    end

    it 'updates name' do
      element = create(:form_element, label: "Hello")

      expect{
        element.update(label: "Goodbye")
      }.to change{ element.reload.name }.from('hello').to('goodbye')
    end
  end
end


require 'rails_helper'

describe FormElement do
  let(:form)    { create(:form) }
  let(:element) { create(:form_element, form: form) }

  describe '.masters' do
    before do
      create(:form_element, master: false)
      create(:form_element, master: true)
    end

    it 'returns only masters' do
      expect(FormElement.masters.map(&:master?)).to eq([true])
    end
  end

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

  describe '#master' do
    it 'can be a master' do
      element = create(:form_element, master: true)
      expect(element.master?).to be true
    end
  end
end


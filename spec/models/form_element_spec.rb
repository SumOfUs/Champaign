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

    describe 'name fixing' do
      it 'keeps name if whitelisted' do
        expect(
          FormElement.create(label: 'My label!', form: form, name: 'address1').name
        ).to eq('address1')
      end

      it 'prefixes custom names' do
        expect(
          FormElement.create(label: 'My label!', form: form, name: 'foo_bar', data_type: 'email').name
        ).to eq('action_foo_bar')
      end

      it 'prefixes names based on checkbox/paragraph types' do
        expect(
            FormElement.create(label: 'My label!', form: form, name: 'foo_bar', data_type: 'checkbox').name
        ).to eq('action_box_foo_bar')
        expect(
            FormElement.create(label: 'My label!', form: form, name: 'foo_bar', data_type: 'paragraph').name
        ).to eq('action_textentry_foo_bar')
        expect(
            FormElement.create(label: 'My label!', form: form, name: 'foo_bar', data_type: 'text').name
        ).to eq('action_textentry_foo_bar')
      end

      it 'does nothing when prefix is present' do
        expect(
          FormElement.create(label: 'My label!', form: form, name: 'action_foo_bar').name
        ).to eq('action_foo_bar')
      end

      it 'does nothing when name is blank' do
        expect(
          FormElement.create(label: 'My label!', form: form, name: '').name
        ).to eq('')
      end

      it 'does nothing when name is "action_"' do
        expect(
          FormElement.create(label: 'My label!', form: form, name: 'action_').name
        ).to eq('action_')
      end
    end
  end

  describe '.update' do
    it 'does not change position' do
      expect do
        element.update(label: "Surname")
      end.to_not change{ element.reload.position}
    end
  end

  describe 'cascading touch' do
    let(:page)      { create(:page) }
    let!(:petition) { create(:plugins_petition, page: page) }

    it 'touches associated records' do
      future = Time.now.utc + 1.hour

      Timecop.freeze(future) do
        petition.form.form_elements.first.update(label: 'foo')
        expect(petition.page.reload.updated_at.to_s).to eq(future.to_s)
      end
    end
  end

  describe 'validations' do
    subject { build(:form_element) }

    it { is_expected.to be_valid }

    describe 'fail when it' do
      it 'has a blank label' do
        subject.label = ''
        expect(subject).not_to be_valid
        expect(subject.errors.keys).to eq [:label]
      end

      it 'has an blank data_type' do
        subject.data_type = ''
        expect(subject).not_to be_valid
        expect(subject.errors.keys).to eq [:data_type]
      end

      it 'has a unknown data_type' do
        subject.data_type = 'state'
        expect(subject).not_to be_valid
        expect(subject.errors.keys).to eq [:data_type]
      end

      it 'has a blank name' do
        subject.name = ''
        expect(subject).not_to be_valid
        expect(subject.errors.keys).to eq [:name]
      end

      it 'has action_ as the name' do
        subject.name = 'action_'
        expect(subject).not_to be_valid
        expect(subject.errors.keys).to eq [:name]
      end

      it 'has bad AK characters in the name' do
        subject.name = 'action_sass matazz'
        expect(subject).not_to be_valid
        expect(subject.errors.messages).to eq({name: ["'action_sass matazz' may only contain numbers, underscores, and lowercase letters."]})
      end

      it "has a name that doesn't match the AK format" do
        subject.name = 'action_'
        expect(subject).not_to be_valid
        expect(subject.errors.messages).to eq({name: ["'action_' is not a permitted ActionKit name."]})
      end
    end
  end
end


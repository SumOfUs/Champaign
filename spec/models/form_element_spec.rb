# frozen_string_literal: true

# == Schema Information
#
# Table name: form_elements
#
#  id            :integer          not null, primary key
#  form_id       :integer
#  label         :string
#  data_type     :string
#  default_value :string
#  required      :boolean
#  visible       :boolean
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  name          :string
#  position      :integer          default("0"), not null
#  choices       :jsonb            default("[]")
#  display_mode  :integer          default("0")
#

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
      let(:base_params) { { label: 'My label!', form: form, name: 'foo_bar' } }

      it 'keeps name if whitelisted' do
        name = FormElement.create(label: 'My label!', form: form, name: 'address1').name
        expect(name).to eq('address1')
      end

      it 'prefixes custom names' do
        name = FormElement.create(label: 'My label!', form: form, name: 'foo_bar', data_type: 'email').name
        expect(name).to eq('action_foo_bar')
      end

      it 'prefixes the name to indicate checkboxes' do
        name = FormElement.create(base_params.merge(data_type: 'checkbox')).name
        expect(name).to eq('action_box_foo_bar')
      end

      it 'prefixes the name to indicate paragraphs' do
        name = FormElement.create(base_params.merge(data_type: 'paragraph')).name
        expect(name).to eq('action_textentry_foo_bar')
      end

      it 'prefixes the name to indicate text' do
        name = FormElement.create(base_params.merge(data_type: 'text')).name
        expect(name).to eq('action_textentry_foo_bar')
      end

      it 'prefixes the name to indicate dropdowns' do
        name = FormElement.create(base_params.merge(data_type: 'dropdown')).name
        expect(name).to eq('action_dropdown_foo_bar')
      end

      it 'prefixes the name to indicate multiple choice' do
        name = FormElement.create(base_params.merge(data_type: 'choice')).name
        expect(name).to eq('action_choice_foo_bar')
      end

      it 'does nothing when prefix is present' do
        name = FormElement.create(label: 'My label!', form: form, name: 'action_foo_bar').name
        expect(name).to eq('action_foo_bar')
      end

      it 'does nothing when name is blank' do
        name = FormElement.create(label: 'My label!', form: form, name: '').name
        expect(name).to eq('')
      end

      it 'does nothing when name is "action_"' do
        name = FormElement.create(label: 'My label!', form: form, name: 'action_').name
        expect(name).to eq('action_')
      end
    end
  end

  describe '.update' do
    it 'does not change position' do
      expect do
        element.update(label: 'Surname')
      end.to_not change { element.reload.position }
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

  describe 'liquid_data' do
    it 'returns just the attributes if it is not a choice' do
      element.data_type = 'text'
      allow(element).to receive(:formatted_choices)
      expect(element.liquid_data).to eq element.attributes.symbolize_keys
      expect(element).not_to have_received(:formatted_choices)
    end

    it 'returns the attributes with choices if its a choice' do
      element.data_type = 'choice'
      element.choices = '["asdf", "qwer"]'
      allow(element).to receive(:formatted_choices).and_return('stubbed')
      expect(element).to receive(:formatted_choices)
      expect(element.liquid_data.keys).to include(:choices)
      expect(element.liquid_data).to eq element.attributes.symbolize_keys.merge(choices: 'stubbed')
    end

    it 'returns the attributes with choices if its a dropdown' do
      element.data_type = 'dropdown'
      element.choices = '["asdf", "qwer"]'
      allow(element).to receive(:formatted_choices).and_return('stubbed')
      expect(element).to receive(:formatted_choices)
      expect(element.liquid_data.keys).to include(:choices)
      expect(element.liquid_data).to eq element.attributes.symbolize_keys.merge(choices: 'stubbed')
    end
  end

  describe 'formatted_choices' do
    before :each do
      element.name = 'action_berry'
    end

    describe 'when the choice is a string' do
      it 'returns the string as the value and label and generates an ID' do
        element.choices = ['Blueberries', 'Or a Blackberry']
        expected1 = { label: 'Blueberries', value: 'Blueberries', id: 'action_berry_blueberries' }
        expected2 = { label: 'Or a Blackberry', value: 'Or a Blackberry', id: 'action_berry_or_a_blackberry' }
        expect(element.formatted_choices).to eq [expected1, expected2]
      end

      it 'returns a properly formatted id' do
        element.choices = ["this - now this! is a DEGENERATE label_    don\'t_you___think"]
        expected = 'action_berry_this_now_this_is_a_degenerate_label_dont_you_think'
        expect(element.formatted_choices.first[:id]).to eq expected
      end
    end

    describe 'when the choice is a hash' do
      let(:expected) { { label: 'This\'ll be fun', value: 'lotsa_fun', id: 'action_berry_lotsa_fun' } }

      it 'returns the hash value for label and value and generates an ID' do
        element.choices = [{ label: "This\'ll be fun", value: 'lotsa_fun' }]
        expect(element.formatted_choices).to eq([expected])
      end

      it 'overrides the id even if one included' do
        element.choices = [{ label: "This'll be fun", value: 'lotsa_fun', id: 'another_id' }]
        expect(element.formatted_choices).to eq([expected])
      end
    end

    describe 'when the choice is nil' do
      it 'returns an empty list' do
        element.choices = nil
        expect(element.formatted_choices).to eq []
      end
    end
  end

  describe 'validation' do
    subject { build(:form_element) }

    it { is_expected.to be_valid }

    describe 'fails when it' do
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
        expect(subject.errors.messages).to eq(name: ["'action_sass matazz' may only contain numbers, underscores, and lowercase letters."])
      end

      it "has a name that doesn't match the AK format" do
        subject.name = 'action_'
        expect(subject).not_to be_valid
        expect(subject.errors.messages).to eq(name: ["'action_' is not a permitted ActionKit name."])
      end
    end

    describe 'of choices' do
      describe 'passes when choices' do
        it 'is nil' do
          subject.choices = nil
          expect(subject).to be_valid
        end

        it 'is empty string' do
          subject.choices = ''
          expect(subject).not_to be_valid
        end

        it 'is an empty list' do
          subject.choices = []
          expect(subject).to be_valid
        end

        it 'is a list of strings' do
          subject.choices = %w[apple orange pear]
          expect(subject).to be_valid
          expect(subject.choices).to eq %w[apple orange pear]
        end

        it 'is a list of hashes with appropriate keys' do
          subject.choices = [{ label: 'Very Satisfied', value: '10' },
                             { label: 'Unsatisfied', value: '1', id: 'some_id' }]
          expect(subject).to be_valid
          expect(subject.choices).to eq [{ 'label' => 'Very Satisfied', 'value' => '10' },
                                         { 'label' => 'Unsatisfied', 'value' => '1', 'id' => 'some_id' }]
        end

        it 'is a list of strings and hashes with appropriate keys' do
          subject.choices = [{ label: 'Very Satisfied', value: '10' },
                             'Blueberry!',
                             { label: 'Unsatisfied', value: '1', id: 'some_id' }]
          expect(subject).to be_valid
          expect(subject.choices).to eq [{ 'label' => 'Very Satisfied', 'value' => '10' },
                                         'Blueberry!',
                                         { 'label' => 'Unsatisfied', 'value' => '1', 'id' => 'some_id' }]
        end

        it 'is a list of objects and one object has a bad key' do
          subject.choices = [{ label: 'Very Satisfied', value: '10' },
                             { label: 'Unsatisfied', value: '1', squid: 'WRONG' }]
          expect(subject).to be_valid
        end
      end

      describe 'fails when choices' do
        it 'is an empty object' do
          subject.choices = '{}'
          expect(subject).to be_invalid
        end

        it 'is an object, even with the right keys' do
          subject.choices = '{label: "Very Satisfied", value: "10"}'
          expect(subject).to be_invalid
        end

        it 'is a list of objects and one object is missing a key' do
          subject.choices = '[{label: "Very Satisfied", value: "10"},
                              {label: "Unsatisfied"}]'
          expect(subject).to be_invalid
        end

        it 'is a good list with one null element' do
          subject.choices = '["apple", "orange", "pear", null]'
          expect(subject).to be_invalid
        end
      end
    end
  end
end

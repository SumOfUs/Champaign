# frozen_string_literal: true
# == Schema Information
#
# Table name: forms
#
#  id            :integer          not null, primary key
#  name          :string
#  description   :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  visible       :boolean          default(FALSE)
#  master        :boolean          default(FALSE)
#  formable_id   :integer
#  formable_type :string
#  position      :integer          default(0), not null
#

require 'rails_helper'

describe Form do
  describe '.masters' do
    before do
      create(:form, master: false)
      create(:form, master: true)
    end

    it 'returns only masters' do
      expect(Form.masters.map(&:master?)).to eq([true])
    end
  end

  describe '#master' do
    it 'can be a master' do
      form = create(:form, master: true)
      expect(form.master?).to be true
    end
  end

  describe 'formable' do
    it 'is polymorphically associated' do
      petition = create(:plugins_fundraiser)

      expect(petition.form).to be_a Form
      expect(Form.last.formable).to eq(petition)
    end
  end

  describe 'validations' do
    context 'name' do
      it 'must be present' do
        expect(Form.new).to_not be_valid
      end

      context 'for non-master' do
        it 'uniqueness is not necessary' do
          create(:form, master: true, name: 'Foo')

          new_form = Form.create(master: false, name: 'Foo')
          expect(new_form.errors[:name]).to be_empty
        end
      end

      context 'for master' do
        it 'must be unique' do
          create(:form, master: true, name: 'Foo')
          new_form = Form.create(master: true, name: 'Foo')
          expect(new_form.errors[:name]).to eq(['must be unique'])
        end
      end
    end
  end
end

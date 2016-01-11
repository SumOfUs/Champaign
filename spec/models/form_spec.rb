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

  describe "polymorphically associated with plugins" do
    it 'assciates' do
      petition = create(:plugins_fundraiser)
      form = create(:form)

      form.update(formable: petition)

      expect(form.formable).to eq(petition)
      expect(petition.reload.form).to eq(form)
    end

    it 'associates the other way' do
      petition = create(:plugins_fundraiser)
      form = create(:form)

      petition.update(form:form)

      expect(petition.reload.form).to eq(form)
      expect(form.formable).to eq(petition)
    end
  end

  describe 'validations' do
    context 'name' do
      it "must be present" do
        expect(Form.new).to_not be_valid
      end

      context 'for non-master' do
        it 'uniqueness is not necessary' do
          create(:form, master: true, name: 'Foo')

          new_form = Form.create(master:false, name: 'Foo')
          expect(new_form.errors[:name]).to be_empty
        end
      end

      context 'for master' do
        it 'must be unique' do
          create(:form, master: true, name: 'Foo')
          new_form = Form.create(master:true, name: 'Foo')
          expect(new_form.errors[:name]).to eq(['must be unique'])
        end
      end
    end
  end
end

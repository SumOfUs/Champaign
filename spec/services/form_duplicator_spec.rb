require 'rails_helper'

describe FormDuplicator do
  let(:form) { create(:form_with_fields) }

  subject(:copy) { FormDuplicator.duplicate(form) }

  describe '.duplicate' do
    it 'duplicates the passed form' do
      expect(copy.id).to_not eq(form.id)
    end

    it 'duplicates elements onto new form' do
      expect(
        copy.form_elements.map(&:name)
      ).to eq(form.form_elements.map(&:name))
    end
  end
end


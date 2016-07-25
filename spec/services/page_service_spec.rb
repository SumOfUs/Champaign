require 'rails_helper'

describe PageService do
  let!(:en_page) { create(:page, active: true, language: create(:language, :english), created_at: 1.year.ago) }
  let!(:en_unpublished) { create(:page, active: false, language: create(:language, :english)) }
  let!(:fr_page) { create(:page, active: true, language: create(:language, :french))  }

  describe '.list' do
    it 'returns pages by language' do
      expect(subject.list(language: 'fr')).to match_array([fr_page])
    end

    it 'returns only published pages' do
      expect(subject.list).to match_array([en_page, fr_page])
    end

    it 'limits result to a 100' do
      expect_any_instance_of(ActiveRecord::QueryMethods).to receive(:limit).with(100){ Page.all }
      subject.list
    end

    it 'orders pages by date (newest first)' do
      expect(subject.list).to match([fr_page, en_page])
    end
  end
end

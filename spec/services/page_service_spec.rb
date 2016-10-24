# frozen_string_literal: true
require 'rails_helper'

describe PageService do
  let(:english) { create(:language, :english) }
  let(:french) { create(:language, :french) }

  describe '.list' do
    let!(:en_page) { create(:page, :published, language: english, updated_at: 1.year.ago) }
    let!(:en_unpublished) { create(:page, :unpublished, language: english) }
    let!(:fr_page) { create(:page, :published, created_at: 1.year.ago, language: french) }

    it 'returns pages by language' do
      expect(subject.list(language: 'fr')).to match_array([fr_page])
    end

    it 'returns only published pages' do
      expect(subject.list).to match_array([en_page, fr_page])
    end

    it 'limits result to 30 by default' do
      expect_any_instance_of(ActiveRecord::QueryMethods).to receive(:limit).with(30) { Page.all }
      subject.list
    end

    it 'limits result by passed value' do
      expect(subject.list(limit: 1).size).to eq(1)
    end

    it 'orders pages by date (most recently updated first)' do
      expect(subject.list).to match([fr_page, en_page])
    end
  end

  describe '.list_featured' do
    let!(:en_page) do
      create(:page, :published, featured: true, language: english, updated_at: 1.year.ago)
    end
    let!(:en_unpublished) { create(:page, :unpublished, language: english) }
    let!(:en_unfeatured) { create(:page, :published, language: english) }
    let!(:fr_page) { create(:page, :published, featured: true, created_at: 1.year.ago, language: french) }

    it 'returns featured pages by language' do
      expect(subject.list_featured(language: 'en')).to match_array([en_page])
    end

    it 'returns only published, featured pages' do
      expect(subject.list_featured).to match_array([en_page, fr_page])
    end

    it 'limits result to 30 by default' do
      expect_any_instance_of(ActiveRecord::QueryMethods).to receive(:limit).with(30) { Page.all }
      subject.list
    end

    it 'limits result by passed value' do
      expect(subject.list(limit: 1).size).to eq(1)
    end

    it 'orders pages by date (most recently updated  first)' do
      expect(subject.list_featured).to match([fr_page, en_page])
    end
  end
end

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

  describe '.list_similar' do
    let(:name_tag) { create :tag, name: 'TuuliP' }
    let(:region_tag) { create :tag, name: '@Germany' }
    let(:issue_tag1) { create :tag, name: '#AnimalRights' }
    let(:issue_tag2) { create :tag, name: '#Sexism' }
    let(:english) { create :language, :english }
    let(:french) { create :language, :french }

    context 'for a page page that has a region tag' do
      let!(:original_page) do
        create(:page,
               :published,
               title: 'Coolest petition',
               content: 'Coolest petition content',
               language: english,
               tags: [name_tag, region_tag, issue_tag1, issue_tag2])
      end

      let!(:one_tag_match) do
        create(:page,
               :published,
               title: 'One tag match',
               language: english,
               tags: [name_tag, region_tag, issue_tag1])
      end

      let!(:region_tag_match) do
        create(:page,
               :published,
               title: 'One tag match',
               language: english,
               featured: true,
               tags: [region_tag])
      end

      let(:name_tag_match) do
        create(:page,
               :published,
               title: 'Only name and region tags match',
               language: english,
               tags: [region_tag, name_tag, create(:tag, name: '#Internetz')])
      end

      context 'similar pages exist' do
        let!(:similar_french_page) do
          create(:page,
                 :published,
                 title: 'Je ne parle pas français',
                 language: french,
                 tags: [name_tag, region_tag, issue_tag1, issue_tag2])
        end

        let!(:similar_page) do
          create(:page,
                 :published,
                 title: 'A similar petition',
                 content: 'Also cool content',
                 language: english,
                 tags: [name_tag, region_tag, issue_tag1, issue_tag2])
        end

        let!(:another_similar_page) do
          create(:page,
                 :published,
                 title: 'Another very similar petition',
                 content: 'Also way cool content',
                 language: english,
                 tags: [name_tag, region_tag, issue_tag1, issue_tag2])
        end

        let!(:a_third_similar_page) do
          create(:page,
                 :published,
                 title: 'Very very similar...',
                 content: 'Such cool many wow!',
                 language: english,
                 tags: [name_tag, region_tag, issue_tag1, issue_tag2])
        end

        let!(:similar_unpublished) do
          create(:page,
                 :unpublished,
                 title: 'Similar but unpublished',
                 language: english,
                 tags: [name_tag, region_tag, issue_tag1, issue_tag2])
        end

        it 'returns the specified number of pages with tags that are similar to the original page' do
          expect(subject.list_similar(original_page, limit: 3).size).to eq(3)
        end

        it 'does not return pages that have no matching issue tag' do
          expect(subject.list_similar(original_page, limit: 3)).to_not include(name_tag_match)
        end

        it 'does not return pages that match by tags but are different language' do
          expect(subject.list_similar(original_page)).to_not include(similar_french_page)
        end

        it 'does not return unpublished pages' do
          expect(subject.list_similar(original_page)).to_not include(similar_unpublished)
        end

        it 'does not return the original page' do
          expect(subject.list_similar(original_page)).to_not include(original_page)
        end
      end

      context 'insufficient number of similar pages' do
        it 'falls back to pages with fewer matching issue tags if there are otherwise not enough similar pages' do
          expect(subject.list_similar(original_page, limit: 4)).to include(one_tag_match)
        end

        it 'falls back to recent featured petitions with the same region tag if there are no matches by issue tag' do
          expect(subject.list_similar(original_page, limit: 4)).to include(region_tag_match)
        end
      end
    end

    context 'for a page that has no region tag' do
      let(:global_region_tag) { create :tag, name: '@Global' }

      let!(:no_region_tag_page) do
        create(:page,
               id: 321,
               language: english,
               tags: [name_tag, issue_tag1, issue_tag2])
      end

      let!(:global_region_page) do
        create(:page,
               :published,
               :featured,
               id: 425,
               language: english,
               tags: [name_tag, global_region_tag, issue_tag1])
      end

      it 'falls back to the @Global region tag' do
        expect(subject.list_similar(no_region_tag_page, limit: 1)).to match([global_region_page])
      end
    end
  end
end

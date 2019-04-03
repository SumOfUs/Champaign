# frozen_string_literal: true

RSpec.shared_context 'shared language pages' do
  let!(:german) { create :language, :german }
  let!(:french) { create :language, :french }
  let!(:english) { create :language, :english }
  let!(:spanish) { create :language, :spanish }

  before do
    @page_hash = Language.all.inject({}) do |languages, language|
      languages[language.code.to_sym] = {
        ordinary: create_list(:page, 1, language: language, featured: false),
        featured: create_list(:page, 1, language: language, featured: true)
      }
      languages
    end
  end
end

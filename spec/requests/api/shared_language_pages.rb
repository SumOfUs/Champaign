RSpec.shared_context "shared language pages" do

  let!(:german) { create :language, :german }
  let!(:french) { create :language, :french }
  let!(:english) { create :language, :english }
  let!(:spanish) { create :language, :spanish }

  before do
    @page_hash = {}
    Language.all.each do |language|
      @page_hash[language.code.to_sym] = {
          ordinary: create_list(:page, 1, language: language, featured: false),
          featured: create_list(:page, 1, language: language, featured: true)
      }
    end
  end

end

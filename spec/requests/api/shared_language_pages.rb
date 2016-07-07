RSpec.shared_context "shared language pages" do
  let!(:german) { create :language, :german }
  let!(:french) { create :language, :french }
  let!(:english) { create :language, :english }
  let!(:spanish) { create :language, :spanish }

  @page_hash = {}
  # Problem: Language.all.each is nil unless it's called inside a example `it` block, so it never enters the loop
  Language.all.each do |language|
    pp "This never gets printed because the loop runs over an empty array"
    let!(:ordinary) { create_list :page, 10, language: language, featured: false }
    let!(:featured) { create_list :page, 10, language: language, featured: true }
    @page_hash[language.code.to_sym] = {
        ordinary: ordinary,
        featured: featured
    }
  end
end

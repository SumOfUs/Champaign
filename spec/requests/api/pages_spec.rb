require 'rails_helper'

describe "api/pages" do

  def json
    JSON.parse(response.body)
  end

  let(:shared_language_pages) {
    let(:german) { create :language, traits: :german }
    let(:french) { create :language, traits: :french }
    let(:english) { create :language, traits: :english }
    let(:spanish) { create :language, traits: :spanish }

    # TODO: MAKE INTO SHARED EXAMPLES FOR FEATURED AND PAGE SHOW SPECS
    page_hash = {}
    Language.all.each do |language|
      let!(:ordinray) { create_list :page, 10, language: language, featured: false }
      let!(:featured) { create_list :page, 10, language: language, featured: true }
      page_hash[language.code.to_sym] = {
          ordinary: ordinary,
          featured: featured
      }
    end
  }

  before :each do
    # I'm rounding the time. Ruby deals with time in nanoseconds whereas the database deals with time in microsecond
    # precision. If I don't round the time, the expectation comparing the JSON response expects data from the DB
    # with nanosecond precision.
    @time_now = Time.at(Time.now.to_i)
    allow(Time).to receive(:now).and_return(@time_now)
  end

  describe 'GET pages' do
    context 'with no specified language' do
      let!(:featured_pages) { create_list :page, 50, featured: true }
      let!(:mvp_pages) { create_list :page, 50, featured: false }
      let!(:last_featured_page) { create :page, title: 'I am the latest featured page', featured: true, slug: 'garden_slug' }
      let!(:last_mvp_page) { create :page, title: 'I am the latest test page', featured: false}

      it 'gets a hundred of both featured and unfeatured pages in a reversed order if requested without an id' do
        get api_pages_path
        expect(response).to be_success
        # Includes both featured and unfeatured pages.
        expect(json).to include last_featured_page.as_json
        expect(json).to include last_mvp_page.as_json
        # Limits its reach to the latest hundred pages if there are more than a hundred pages to search through.
        expect(json).to match Page.last(100).reverse.as_json
      end

      it 'gets a single page if searched by an id of a page that exists' do
        get api_pages_path(:id => last_mvp_page.id.to_s)
        expect(response).to be_success
        expect(json).to match last_mvp_page.as_json
      end

      it 'gets a single page if searched by a slug of a page that exists' do
        get api_pages_path(:id => last_featured_page.slug)
        expect(response).to be_success
        expect(json).to match last_featured_page.as_json
      end

      it 'returns an error if searching for an ID or slug of a page that does not exist' do
        get api_pages_path(:id => last_featured_page.slug + '_epidemic')
        expect(response.status).to eq(404)
        expect(json).to match({ "errors" => "No record was found with that slug or ID."})
      end
    end

    context 'with languages' do
      describe 'with language that does not exist' do
        it 'returns json with error' do
          get api_pages_path, {language: 'klingon'}
          expect(json).to match({"errors" => "The language you requested is not supported."})
          expect(response.status).to eq(404)
        end
      end
    end

    describe 'with languages that exist' do
      shared_language_pages

      Language.all.each do |language|
        it "in #{language.name}, it gets pages only in that language" do
          get api_pages_path, { language: language.code }
          expect(json).to_match Page.last(100).reverse.as_json
        end
      end

    end

  end

  describe 'GET featured' do
    context 'with no specified language' do
      let!(:featured_pages) { create_list :page, 50, featured: true }
      let!(:mvp_pages) { create_list :page, 50, featured: false }
      it 'gets only featured pages' do
        get api_pages_featured_path
        expect(response).to be_success
        expect(json).to match featured_pages.as_json
        mvp_pages.map{|mvp_page| expect(json).to_not include mvp_page.as_json}
      end
    end

    context 'with languages' do
      describe 'with language that does not exist' do
        it 'returns json with error' do
          get api_pages_featured_path, {language: 'klingon'}
          expect(json).to match({"errors" => "The language you requested is not supported."})
          expect(response.status).to eq(404)
        end
      end
      describe 'with languages that exist' do
        shared_language_pages
      end
    end

  end
end

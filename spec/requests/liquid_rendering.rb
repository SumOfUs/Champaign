require "rails_helper"

describe "Liquid page rendering" do

  LiquidMarkupSeeder.titles.each do |title|

    describe "page with layout #{title}" do
      [:en, :fr].each do |language|

        it "can render in #{language} without errors" do
          LiquidMarkupSeeder.seed(quiet: true) # transactional fixtures nuke em every test :/
          layout = LiquidLayout.find_by(title: title)
          page = create :page, liquid_layout: layout

          get "/pages/#{page.id}"
          expect(response).to be_successful
          expect(response).to render_template(:show)
        end
      end
    end
  end

  describe 'rendering sidebars' do

    before :each do
      LiquidMarkupSeeder.seed(quiet: true) # transactional fixtures nuke em every test :/
    end

    it 'renders the fundraiser sidebar' do
      page = create :page, liquid_layout: LiquidLayout.find_by(title: "Standard Fundraiser")
      get "/pages/#{page.id}"
      expect(response.body).to include('<div class="fundraiser-bar__content">')
    end

    it 'renders the fundraiser sidebar' do
      page = create :page, liquid_layout: LiquidLayout.find_by(title: "Standard Petition")
      get "/pages/#{page.id}"
      expect(response.body).to include('<div class="petition-bar__content">')
    end

  end
end
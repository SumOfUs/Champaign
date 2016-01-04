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
end
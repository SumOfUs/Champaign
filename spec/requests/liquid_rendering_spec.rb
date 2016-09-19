# frozen_string_literal: true
require 'rails_helper'

describe 'Liquid page rendering' do
  before(:all) do
    LiquidMarkupSeeder.seed(quiet: true) # transactional fixtures nuke em every test :/
  end

  after(:all) do
    LiquidLayout.delete_all
    LiquidPartial.delete_all
  end

  LiquidMarkupSeeder.titles.each do |title|
    describe "page with layout #{title}" do
      [:en, :fr, :de].each do |language_code|
        it "can render in #{language_code} without errors" do
          language = create :language, code: language_code
          layout = LiquidLayout.find_by(title: title)

          unless LiquidTagFinder.new(layout.content).skip_smoke_tests?
            page = create :page, liquid_layout: layout, language: language

            get "/pages/#{page.id}"
            expect(response).to be_successful
            expect(response).to render_template(:show)
          end
        end
      end
    end
  end

  describe 'rendering sidebars' do
    it 'renders the fundraiser sidebar' do
      page = create :page, liquid_layout: LiquidLayout.find_by(title: 'Fundraiser With Large Image')
      get "/pages/#{page.id}"
      expect(response.body).to include('<div class="fundraiser-bar__content">')
    end

    it 'renders the petition sidebar' do
      page = create :page, liquid_layout: LiquidLayout.find_by(title: 'Petition With Large Image')
      get "/pages/#{page.id}"
      expect(response.body).to include('<div class="petition-bar__content">')
    end
  end
end

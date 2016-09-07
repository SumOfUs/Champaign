# frozen_string_literal: true
require 'rails_helper'

describe 'Liquid page rendering' do
  LiquidMarkupSeeder.titles.each do |title|
    describe "page with layout #{title}" do
      [:en, :fr, :de].each do |language_code|
        it "can render in #{language_code} without errors" do
          language = create :language, code: language_code
          LiquidMarkupSeeder.seed(quiet: true) # transactional fixtures nuke em every test :/
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
end

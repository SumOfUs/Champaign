# frozen_string_literal: true

require 'rails_helper'

describe 'Liquid page rendering' do
  before(:all) do
    LiquidMarkupSeeder.seed(quiet: true)
  end

  before(:each) do
    allow_any_instance_of(Money).to receive(:exchange_to)
  end

  after(:all) do
    DatabaseCleaner.clean_with(:truncation)
  end

  LiquidMarkupSeeder.titles.each do |title|
    describe "page with layout #{title}" do
      %i[en fr de es].each do |language_code|
        it "can render in #{language_code} without errors" do
          language = create :language, code: language_code
          layout = LiquidLayout.find_by!(title: title)

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

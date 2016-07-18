require "rails_helper"

describe 'Localization for pages' do
  Champaign::Application.config.i18n.available_locales.each do |locale|
    it "sets localization for a page in #{locale}" do
      page = create :page, language: (create :language, code: locale)
      get "/pages/#{page.id}"
      expect(response).to be_successful
      expect(I18n.locale).to eq locale
    end

    it "resets localization back from #{locale} to default if a non-localized page is requested afterwards" do
      page = create :page, language: (create :language, code: locale)
      get "/pages/#{page.id}"
      expect(response).to be_successful
      expect(I18n.locale).to eq locale
      get "/users/sign_in"
      expect(response).to be_successful
      expect(I18n.locale).to eq I18n.default_locale
    end
  end

  it "uses default locale for a page where localization isn't required" do
    get "/users/sign_in"
    expect(response).to be_successful
    expect(I18n.locale).to eq I18n.default_locale
  end

  it "uses the correct locale if two localized pages are requested in a row" do
    english_page = create :page, language: (create :language, code: :en)
    french_page = create :page, language: (create :language, code: :fr)
    get "/pages/#{english_page.id}"
    expect(response).to be_successful
    expect(I18n.locale).to eq :en

    get "/pages/#{french_page.id}"
    expect(response).to be_successful
    expect(I18n.locale).to eq :fr
  end
end

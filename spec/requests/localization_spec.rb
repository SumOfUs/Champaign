# frozen_string_literal: true

require 'rails_helper'

describe 'Localization for pages' do
  let(:english_page) { create :page, language: (create :language, code: :en) }
  let(:german_page) { create :page, language: (create :language, code: :de) }
  let(:form) { create :form_with_email_and_name }
  let(:form_params) { { form_id: form.id, email: 'asdf@test.com', name: 'Metiulous Tester' } }

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
      get '/users/sign_in'
      expect(response).to be_successful
      expect(I18n.locale).to eq I18n.default_locale
    end
  end

  it "uses default locale for a page where localization isn't required" do
    get '/users/sign_in'
    expect(response).to be_successful
    expect(I18n.locale).to eq I18n.default_locale
  end

  it 'uses the correct locale if two localized pages are requested in a row' do
    english_page = create :page, language: (create :language, code: :en)
    french_page = create :page, language: (create :language, code: :fr)
    get "/pages/#{english_page.id}"
    expect(response).to be_successful
    expect(I18n.locale).to eq :en

    get "/pages/#{french_page.id}"
    expect(response).to be_successful
    expect(I18n.locale).to eq :fr
  end

  it 'resets to default locale viewing a back-end page after taking action on another language page' do
    expect(I18n.default_locale).not_to eq :de
    login_as(create(:user), scope: :user)

    get '/pages'
    expect(response).to be_successful
    expect(I18n.locale).to eq I18n.default_locale

    get "/a/#{german_page.slug}"
    post "/api/pages/#{german_page.id}/actions",
         params: form_params.merge(page_id: german_page.id)
    expect(response).to be_successful
    expect(I18n.locale).to eq :de

    get '/pages'
    expect(response).to be_successful
    expect(I18n.locale).to eq I18n.default_locale
  end

  it "validates in the current page's language" do
    get "/a/#{german_page.slug}"
    post "/api/pages/#{german_page.id}/actions/validate",
         params: form_params.merge(page_id: german_page.id)
    expect(response).to be_successful
    expect(I18n.locale).to eq :de
    post "/api/pages/#{german_page.id}/actions",
         params: form_params.merge(page_id: german_page.id)
    expect(response).to be_successful
    expect(I18n.locale).to eq :de

    get "/a/#{english_page.slug}"
    post "/api/pages/#{english_page.id}/actions/validate",
         params: form_params.merge(page_id: english_page.id)
    expect(response).to be_successful
    expect(I18n.locale).to eq :en
    post "/api/pages/#{english_page.id}/actions",
         params: form_params.merge(page_id: english_page.id)
    expect(response).to be_successful
    expect(I18n.locale).to eq :en
  end

  it 'mails and shows member auth signup with language of most recent page' do
    allow(ConfirmationMailer).to receive(:confirmation_email) { double(deliver_now: true) }

    get "/a/#{german_page.slug}"
    post "/api/pages/#{german_page.id}/actions",
         params: form_params.merge(page_id: german_page.id)
    get '/member_authentication/new', params: { email: form_params[:email] }
    expect(response).to be_successful
    expect(I18n.locale).to eq :de
    post '/member_authentication',
         params: {
           email: 'asdf@test.com', password: 'asdfasdf', password_confirmation: 'asdfasdf'
         }
    expect(ConfirmationMailer).to have_received(:confirmation_email).with(a_hash_including(language: :de))
  end
end

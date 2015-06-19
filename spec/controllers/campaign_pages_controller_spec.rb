require 'rails_helper'
require 'capybara/poltergeist'
require 'helper_functions'

RSpec.describe CampaignPagesController, type: :feature do
  scenario 'Redirect after a user signs the petition' do
    cam_page = create_petition_page
    visit "/campaign_pages/#{cam_page.id}"
    expect(find('#redirect-location')).to have_text 'www.google.com'
  end

  scenario 'Index displays the list of active campaign pages' do
    cam_page = create_petition_page
    log_in
    visit '/campaign_pages'
    expect(page.body).to have_text cam_page.title
  end

  scenario 'Index page for disabled pages displays the list of disabled pages' do
    cam_page = create_petition_page
    cam_page.active = false
    cam_page.save
    log_in
    visit '/campaign_pages?disabled=1'
    expect(page.body).to have_text cam_page.title
  end
end



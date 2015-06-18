require 'rails_helper'
require 'capybara/poltergeist'
require 'helper_functions'

RSpec.describe CampaignPagesController, type: :feature do
  scenario 'Redirect after a user signs the petition' do
    cam_page = create_petition_page
    visit "/campaign_pages/#{cam_page.id}"
    expect(find('#redirect-location')).to have_text 'www.google.com'
  end
end



require 'rails_helper'

describe 'Campaigns' do
  scenario 'raises an error if trying to show a deactivated campaign' do
    campaign = Campaign.create! campaign_name: 'Deactivated Campaign', active: false
    log_in

    expect {
      visit "/campaigns/#{campaign.id}"
    }.to raise_error(ActionController::RoutingError)
  end
end

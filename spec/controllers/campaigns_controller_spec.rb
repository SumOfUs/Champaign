require 'rails_helper'

RSpec.describe CampaignsController, type: :request do
  it 'raises an error if trying to show a deactivated campaign' do
    expect {
      campaign = Campaign.create campaign_name: 'Deactivated Campaign', active: false
      get "/campaigns/#{campaign.id}"
    }.to raise_error(ActionController::RoutingError)
  end
end

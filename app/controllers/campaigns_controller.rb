class CampaignsController < ApplicationController
  before_action :authenticate_user!

  def index
    @campaigns = ActiveQuery.new(Campaign)
  end

  def new
    @campaign = Campaign.new
  end

  def create
    @campaign = Campaign.create permitted_params
    redirect_to :campaigns, notice: 'Campaign Created'
  end

  def show
    @campaign = Campaign.find params['id']

    unless @campaign.active?
      raise ActionController::RoutingError.new('The campaign you requested has been deactivated.')
    end
    @templates = ActiveQuery.new(Template)
  end

  def edit
    find_campaign
  end

  def update
    find_campaign
    @campaign.update permitted_params
    redirect_to :campaigns, notice: 'Campaign Updated'
  end

  def destroy
    find_campaign

    # deactivates campaign pages associated with that campaign
    @campaign.campaign_page.update_all(:active =>false)
    # deactivates the campaign itself
    @campaign.update(:active => false)
    redirect_to :campaigns, notice: "The campaign '" + @campaign.campaign_name + "' was deactivated. Contact an admin if you'd like to reactivate it."
  end

  private

  def permitted_params
    CampaignParameters.new(params).permit
  end

  def find_campaign
    @campaign = Campaign.find params['id']
  end
end

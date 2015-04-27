class CampaignsController < ApplicationController

  def index
    @campaigns = Campaign.all
  end

  def new
    @campaign = Campaign.new
  end

  def create
    permitted_params = CampaignParameters.new(params).permit
    @campaign = Campaign.new permitted_params
    @campaign.save
    redirect_to :campaigns
  end

  def show
    @campaign = Campaign.find params['id']
  end

  def edit
    @campaign = Campaign.find params['id']
  end
end

class CampaignsController < ApplicationController

  def index
    @campaigns = Campaign.all
  end

  def new
    @campaign = Campaign.new
  end

  def create
    permitted_params = CampaignParameters.new(params).permit
    @campaign = Campaign.create permitted_params
    redirect_to :campaigns, notice: 'Campaign Created'
  end

  def show
    @campaign = Campaign.find params['id']
  end

  def edit
    @campaign = Campaign.find params['id']
  end

  def update
    @campaign = Campaign.find params['id']
    permitted_params = CampaignParameters.new(params).permit
    @campaign.update permitted_params
    redirect_to :campaigns, notice: 'Campaign Updated'
  end
end

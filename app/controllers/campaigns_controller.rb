class CampaignsController < ApplicationController

  def index
    @campaigns = Campaign.where(:active => true)
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
    if @campaign.active == false
      redirect_to :campaigns, notice: 'The campaign you requested has been deactivated.'
    end 
    @templates = Template.where active: true
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

  def destroy
    @campaign = Campaign.find params['id']
    @campaign.update(:active => false)
    redirect_to :campaigns, notice: "The campaign '" + @campaign.campaign_name + "' was deactivated. Contact an admin if you'd like to reactivate it."
  end
end

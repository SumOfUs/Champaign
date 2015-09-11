class CampaignsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_campaign, only: [:show, :edit, :update, :destroy]

  def index
  end

  def new
    @campaign = Campaign.new
  end

  def create
    @campaign = Campaign.create permitted_params
    redirect_to :campaigns, notice: t('campaigns.create.notice')
  end

  def show
    unless @campaign.active?
      raise ActionController::RoutingError.new( t('campaigns.show.deactivated_notice') )
    end
  end

  def edit
  end

  def update
    @campaign.update permitted_params
    redirect_to :campaigns, notice: t('campaigns.update.notice')
  end

  # Deactives campaign and its associated campaign pages
  def destroy
    @campaign.campaign_page.update_all(active: false)
    @campaign.update(active: false)

    redirect_to :campaigns, notice: t('campaigns.destroy.notice', name: @campaign.name)
  end

  private

  def permitted_params
    params.require(:campaign).permit(:id, :name)
  end

  def find_campaign
    @campaign = Campaign.find params['id']
  end
end

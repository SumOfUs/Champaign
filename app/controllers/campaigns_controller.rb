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
  end

  def edit
  end

  def update
    @campaign.update permitted_params
    redirect_to :campaigns, notice: t('campaigns.update.notice')
  end

  # Deactives campaign and its associated pages
  def destroy
    @campaign.page.update_all(active: false)
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

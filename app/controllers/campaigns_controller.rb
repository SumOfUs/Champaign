# frozen_string_literal: true

class CampaignsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_campaign, only: %i[show edit update destroy]

  def index
  end

  def new
    @campaign = Campaign.new
  end

  def create
    @campaign = CampaignCreator.run campaign_params
    if @campaign.persisted?
      redirect_to :campaigns, notice: t('campaigns.create.notice')
    else
      flash[:error] = t('campaigns.error')
      render :edit, status: :unprocessable_entity
    end
  end

  def show
  end

  def edit
  end

  def update
    if CampaignUpdater.run(@campaign, campaign_params)
      redirect_to :campaigns, notice: t('campaigns.update.notice')
    else
      flash[:error] = t('campaigns.error')
      render :edit, status: :unprocessable_entity
    end
  end

  # Deactives campaign and its associated pages
  def destroy
    @campaign.page.update_all(active: false)
    @campaign.update(active: false)

    redirect_to :campaigns, notice: t('campaigns.destroy.notice', name: @campaign.name)
  end

  private

  def campaign_params
    params.require(:campaign).permit(:id, :name)
  end

  def find_campaign
    @campaign = Campaign.find params['id']
  end
end

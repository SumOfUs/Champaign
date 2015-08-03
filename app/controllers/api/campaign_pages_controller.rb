class Api::CampaignPagesController < ApplicationController
  layout false

  def show
    @campaign_page = CampaignPage.find(params[:id])

    respond_to do |format|
      format.json
    end
  end
end


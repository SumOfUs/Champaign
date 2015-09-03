require 'share_progress'

class Share::TwittersController < Share::SharesController
  before_filter :find_campaign_page

  def index
    @variations = Share::Twitter.where(campaign_page_id: @campaign_page.id)
    render 'share/index'
  end

  def new
    @twitter = Share::Twitter.new(description: "#{@campaign_page.title} {LINK}")
    render 'share/new'
  end

  def edit
    @twitter = Share::Twitter.find params[:id]
    render 'share/edit'
  end

  def create
    ShareProgressVariantBuilder.create(permitted_params, {
      variant_type: :twitter,
      campaign_page: @campaign_page,
      url: campaign_page_url(@campaign_page)
    })

    respond_to do |format|
      format.html { redirect_to campaign_page_share_twitters_path(@campaign_page)}
      format.json { render json: {}, status: :ok }
    end
  end

  def update
    ShareProgressVariantBuilder.update(permitted_params, {
      variant_type: :twitter,
      campaign_page: @campaign_page,
      url: campaign_page_url(@campaign_page),
      id: params[:id]
    })

    respond_to do |format|
      format.html { redirect_to campaign_page_share_twitters_path(@campaign_page)}
    end
  end

  private

  def find_campaign_page
    @campaign_page = CampaignPage.find params[:campaign_page_id]
  end

  def permitted_params
    params.require(:share_twitter).
      permit(:description)
  end
end


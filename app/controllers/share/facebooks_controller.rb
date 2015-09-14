require 'share_progress'

class Share::FacebooksController < Share::SharesController
  before_filter :find_campaign_page

  def new
    @facebook = Share::Facebook.new(
      title: @campaign_page.title,
      description: ActionView::Base.full_sanitizer.sanitize(@campaign_page.content).split('.')[0]
    )

    render 'share/new'
  end

  def update
    ShareProgressVariantBuilder.update(permitted_params, {
      variant_type: :facebook,
      campaign_page: @campaign_page,
      url: campaign_page_url(@campaign_page),
      id: params[:id]
    })

    respond_to do |format|
      format.html { redirect_to campaign_page_share_facebooks_path(@campaign_page)}
    end
  end

  def edit
    @facebook = Share::Facebook.find params[:id]
    render 'share/edit'
  end

  def create
    ShareProgressVariantBuilder.create(permitted_params, {
      variant_type: :facebook,
      campaign_page: @campaign_page,
      url: campaign_page_url(@campaign_page)
    })

    respond_to do |format|
      format.html { redirect_to campaign_page_share_facebooks_path(@campaign_page)}
      format.json { render json: {}, status: :ok }
    end
  end

  def index
    @variations = Share::Facebook.where(campaign_page_id: @campaign_page.id)

    render 'share/index'
  end

  private

  def permitted_params
    params.require(:share_facebook).
      permit(:title, :image, :description)
  end

  def find_button
    @button = Share::Button.find params[:button_id]
  end

  def find_campaign_page
    @campaign_page = CampaignPage.find params[:campaign_page_id]
  end
end


require 'share_progress'

class Share::EmailsController < Share::SharesController
  before_filter :find_campaign_page

  def index
    @variations = Share::Email.where(campaign_page_id: @campaign_page.id)
    render 'share/index'
  end

  def new
    @email = Share::Email.new(
      subject: @campaign_page.title,
      body: "#{ActionView::Base.full_sanitizer.sanitize(@campaign_page.content).split('.')[0]} {LINK}"
    )

    render 'share/new'
  end

  def edit
    @email = Share::Email.find params[:id]
    render 'share/edit'
  end

  def create
    ShareProgressVariantBuilder.create(permitted_params, {
      variant_type: :email,
      campaign_page: @campaign_page,
      url: campaign_page_url(@campaign_page)
    })

    respond_to do |format|
      format.html { redirect_to campaign_page_share_emails_path(@campaign_page)}
      format.json { render json: {}, status: :ok }
    end
  end

  def update
    ShareProgressVariantBuilder.update(permitted_params, {
      variant_type: :email,
      campaign_page: @campaign_page,
      url: campaign_page_url(@campaign_page),
      id: params[:id]
    })

    respond_to do |format|
      format.html { redirect_to campaign_page_share_emails_path(@campaign_page)}
    end
  end


  private

  def find_campaign_page
    @campaign_page = CampaignPage.find params[:campaign_page_id]
  end

  def permitted_params
    params.require(:share_email).
      permit(:subject, :body)
  end
end

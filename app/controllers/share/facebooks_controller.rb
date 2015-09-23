class Share::FacebooksController < Share::SharesController

  private

  def new_defaults
    {
     title: @campaign_page.title,
     description: ActionView::Base.full_sanitizer.sanitize(@campaign_page.content).split('.')[0]
    }
  end

  def share_class
    Share::Facebook
  end

  def permitted_params
    params.require(:share_facebook).
      permit(:title, :image, :description)
  end
end


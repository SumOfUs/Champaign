class Share::EmailsController < Share::SharesController

  private

  def new_defaults
    {
      subject: @campaign_page.title,
      body: "#{ActionView::Base.full_sanitizer.sanitize(@campaign_page.content).split('.')[0]} {LINK}"
    }
  end

  def permitted_params
    params.require(:share_email).
      permit(:subject, :body)
  end

  def share_class
    Share::Email
  end
end


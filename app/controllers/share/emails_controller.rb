# frozen_string_literal: true
class Share::EmailsController < Share::SharesController
  private

  def new_defaults
    {
      subject: @page.title,
      body: "#{ActionView::Base.full_sanitizer.sanitize(@page.content).split('.')[0]} {LINK}"
    }
  end

  def permitted_params
    params
      .require(:share_email)
      .permit(:subject, :body, :url)
  end

  def share_class
    Share::Email
  end
end

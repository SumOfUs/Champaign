# frozen_string_literal: true

class Share::FacebooksController < Share::SharesController
  private

  def new_defaults
    {
      title: @page.title,
      description: ActionView::Base.full_sanitizer.sanitize(@page.content).split('.')[0]
    }
  end

  def share_class
    Share::Facebook
  end

  def permitted_params
    params
      .require(:share_facebook)
      .permit(:title, :image_id, :description, :name)
  end
end

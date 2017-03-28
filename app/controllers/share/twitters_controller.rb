# frozen_string_literal: true
class Share::TwittersController < Share::SharesController
  private

  def new_defaults
    { description: "#{@page.title} {LINK}" }
  end

  def permitted_params
    params
      .require(:share_twitter)
      .permit(:description)
  end

  def share_class
    Share::Twitter
  end
end

# frozen_string_literal: true

class Share::WhatsappsController < Share::SharesController
  private

  def new_defaults
    { text: "#{@page.title} {LINK}" }
  end

  def permitted_params
    params
      .require(:share_whatsapp)
      .permit(:text)
  end

  def share_class
    Share::Whatsapp
  end
end

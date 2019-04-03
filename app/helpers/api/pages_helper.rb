# frozen_string_literal: true

module Api::PagesHelper
  def image_url(page)
    path = page.primary_image.try(:content).try(:url, :medium)
    return '' if path.blank?

    URI.join(ActionController::Base.asset_host, path).to_s
  end
end

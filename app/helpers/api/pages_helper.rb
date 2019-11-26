# frozen_string_literal: true

module Api::PagesHelper
  def image_url(page, size = 'medium')
    path = page.primary_image.try(:content).try(:url, size)
    return '' if path.blank?

    URI.join(ActionController::Base.asset_host, path).to_s
  end

  # List all images required for api/featured.json
  def images_src_set(page)
    %w[medium medium_square large].each_with_index.collect do |size, index|
      image_url(page, size).to_s + " #{index + 1}x"
    end
  end
end

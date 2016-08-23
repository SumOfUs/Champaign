# frozen_string_literal: true
json.array! @pages do |page|
  json.extract! page, :id, :title, :slug, :content, :created_at, :updated_at, :publish_status, :featured, :action_count
  json.language page.language.code
  json.image URI.join(ActionController::Base.asset_host, (page.primary_image.try(:content).try(:url, :medium) || '')).to_s
  json.url member_facing_page_url(page)
end

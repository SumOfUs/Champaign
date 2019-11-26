# frozen_string_literal: true

json.array! @pages do |page|
  json.extract!(
    page,
    :id,
    :title,
    :slug,
    :content,
    :created_at,
    :updated_at,
    :publish_status,
    :featured,
    :action_count,
    :campaign_action_count,
    :plugin_names
  )
  json.language page.language.code
  json.image image_url(page)
  json.imageset images_src_set(page).compact
  json.url member_facing_page_url(page)
  json.donation_page page.donation_page?
  json.percentage_completed page.plugin_thermometer_data.dig(:percentage).to_f
end

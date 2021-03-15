# frozen_string_literal: true

json.extract!(
  @page,
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
  :share_buttons,
)
json.primary_image @page.image_to_display.try(:content).try(:url)
json.language @page.language.code

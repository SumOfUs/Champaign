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
petition =  @page.plugins.select { |p| p.class.name == 'Plugins::Petition' }.first

if petition
  if petition.form
    json.form petition.form.form_elements.order(:position)
  end

  json.cta petition.cta
  json.target petition.target
  json.description petition.description
end



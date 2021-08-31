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
  :meta_description
)

share_buttons = @page.share_buttons.to_a.map do |share|
  share = share.attributes
  share['rank'] = case share['share_type']
  when 'facebook' then 0
  when 'twitter' then 1
  when 'whatsapp' then 2
  when 'email' then 3
  end

  share
end

share_buttons.sort_by! { |hsh| hsh['rank'] }

json.share_buttons share_buttons

image = @page.image_to_display

if image && image.try(:content)
  if image.dimensions
    w,h = image.dimensions.split(":")

    json.width w 
    json.height h
  end
  
  json.image do
    json.original do 
      json.url image.content.url
      json.path image.content.path
    end
    json.large do 
      json.path image.content.path(:large)
      json.url image.content.url(:large)
    end
  end
end

json.language @page.language.code
petition =  @page.plugins.select { |p| p.class.name == 'Plugins::Petition' }.first
fundraiser = @page.plugins.select { |p| p.class.name == 'Plugins::Fundraiser' }.first

json.petition do 
  if petition
    if petition.form
      json.form petition.form.form_elements.order(:position)
      json.form_id petition.form.id
    end

    json.cta petition.cta
    json.target petition.target
    json.description petition.description
  end
end

json.fundraiser do 
  if fundraiser
    if fundraiser.form
      json.form fundraiser.form.form_elements.order(:position)
      json.form_id fundraiser.form.id
    end
  end
end

json.sources do
  json.array! @page.links, :title, :source, :url, :date
end


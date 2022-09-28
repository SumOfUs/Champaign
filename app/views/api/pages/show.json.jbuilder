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
  :meta_description,
  :post_action_copy
)

json.template_name  @page.liquid_layout.title
json.follow_up_template @page.follow_up_liquid_layout

share_buttons = @page.share_buttons.to_a.map do |share|
  share = share.attributes
  share['title'] = case share['share_type']
                   when 'whatsapp' 
                   @page.shares.select{|obj| obj.button_id == share['id']}.pluck(:text).first
  end
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
post_action_image = @page.post_action_image_to_display

if image&.try(:content)
  if image.dimensions
    w, h = image.dimensions.split(':')

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

if post_action_image&.try(:content)
  if post_action_image.dimensions
    w, h = post_action_image.dimensions.split(':')

    json.width w
    json.height h
  end

  json.post_action_image do
    json.original do
      json.url post_action_image.content.url
      json.path post_action_image.content.path
    end
    json.large do
      json.path post_action_image.content.path(:large)
      json.url post_action_image.content.url(:large)
    end
  end
end

json.language @page.language.code

petition =  @page.plugins.select { |p| p.class.name == 'Plugins::Petition' }.first
fundraiser = @page.plugins.select { |p| p.class.name == 'Plugins::Fundraiser' }.first
actionsThermometer = @page.plugins.select { |p| p.class.name == 'Plugins::ActionsThermometer' }.first
donationsThermometer = @page.plugins.select { |p| p.class.name == 'Plugins::DonationsThermometer' }.first

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
    liquid_data = fundraiser.liquid_data
    if fundraiser.form
      json.form fundraiser.form.form_elements.order(:position)
      json.form_id fundraiser.form.id
    end
    if liquid_data
      json.extract! liquid_data, :donation_bands
    end
    json.title fundraiser.title
  end
end

json.thermometer do 
  if actionsThermometer
    json.actions actionsThermometer
  end
  if donationsThermometer
    json.donations donationsThermometer
  end
end

json.sources do
  json.array! @page.links, :title, :source, :url, :date
end

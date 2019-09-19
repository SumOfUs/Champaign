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
  json.url member_facing_page_url(page)
  json.donation_page page.donation_page?

  json.plugins_info page.plugin_thermometers do |thermometer|
    data = thermometer.liquid_data || {}
    json.id thermometer.id
    json.offset thermometer.offset
    json.active thermometer.active

    if thermometer.type == 'ActionsThermometer'
      json.remaining data.dig(:remaining)
      json.signatures data.dig(:signatures)
      json.goals data.dig(:goal_k)

    elsif thermometer.type == 'DonationsThermometer'
      json.percentage data.dig(:percentage)
      json.total_donations data.dig(:total_donations)
      json.goals data.dig(:goals)
    end
  end
end

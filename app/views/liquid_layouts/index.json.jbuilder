# frozen_string_literal: true

json.array!(@liquid_layouts) do |liquid_layout|
  json.extract! liquid_layout, :id, :title, :content
  json.url liquid_layout_url(liquid_layout, format: :json)
end

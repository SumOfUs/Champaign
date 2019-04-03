# frozen_string_literal: true

json.array!(@liquid_partials) do |liquid_partial|
  json.extract! liquid_partial, :id, :title, :content
  json.url liquid_partial_url(liquid_partial, format: :json)
end

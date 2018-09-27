# frozen_string_literal: true
@data.keys.each do |key|
  json.set! key.to_sym, @data[key]
end

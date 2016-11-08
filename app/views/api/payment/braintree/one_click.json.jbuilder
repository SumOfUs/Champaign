# frozen_string_literal: true
json.success @result.success?
unless @result.success?
  json.params @result.params
  json.errors @result.errors
  json.message @result.message
end

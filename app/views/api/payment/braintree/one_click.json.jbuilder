# frozen_string_literal: true
json.success @result.success?
json.params @result.params unless @result.success?
json.errors @result.errors unless @result.success?
json.message @result.message unless @result.success?

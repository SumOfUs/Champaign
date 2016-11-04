# frozen_string_literal: true
json.success @result.success?
json.params @result.params if @result.params
json.errors @result.errors if @result.errors
json.message @result.message if @result.message

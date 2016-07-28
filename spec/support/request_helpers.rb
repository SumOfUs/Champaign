# frozen_string_literal: true
module Requests
  module JsonHelpers
    def json
      JSON.parse(response.body, object_class: OpenStruct)
    end
  end
end

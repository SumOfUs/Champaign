# frozen_string_literal: true
module Requests
  # Utility methods for converting JSON strings to hashes and ostructs
  module JsonHelpers
    def json_ostruct
      JSON.parse(response.body, object_class: OpenStruct)
    end

    def json_hash
      JSON.parse(response.body)
    end
  end
end

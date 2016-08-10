# frozen_string_literal: true
module Requests
  # Utility methods for converting JSON strings to hashes and ostructs
  module RequestHelpers
    def json_ostruct
      JSON.parse(response.body, object_class: OpenStruct)
    end

    def json_hash
      JSON.parse(response.body)
    end

    # Add support for testing `options` requests in RSpec.
    # See: https://github.com/rspec/rspec-rails/issues/925
    def options(*args)
      reset! unless integration_session
      integration_session.__send__(:process, :options, *args).tap do
        copy_session_variables!
      end
    end
  end
end

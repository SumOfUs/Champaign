# frozen_string_literal: true
module CallTool::TwimlGenerator
  class Base
    include Rails.application.routes.url_helpers

    attr_reader :call

    def self.run(call, params = {})
      new(call, params).run
    end

    def initialize(call, params = {})
      @call = call
      @params = params
    end
  end
end

module Plugins
  class CallToolsController < BaseController
    private

    def permitted_params
      params
        .require(:plugins_call_tool)
        .permit(:targets, :active)
    end

    def plugin_class
      ::Plugins::CallTool
    end

    def plugin_symbol
      raise "undefined method"
    end
  end
end

module Plugins
  class CallToolsController < BaseController
    private

    def permitted_params
      call_params = params.require(:plugins_call_tool).permit(:targets, :active)
      #TODO handle JSON parsing errors (in the model maybe?)
      call_params[:targets] = JSON.parse(call_params[:targets])
      call_params
    end

    def plugin_class
      ::Plugins::CallTool
    end

    def plugin_symbol
      raise "undefined method"
    end
  end
end

module Plugins
  class CallToolsController < BaseController
    def update
      @call_tool = Plugins::CallTool.find(params[:id])
      updater = ::CallTool::PluginUpdater.new(@call_tool, update_params)
      if updater.run
        render json: {}
      else
        render json: { errors: updater.errors, name: :plugins_call_tool }, status: :unprocessable_entity
      end
    end

    private

    def update_params
      params.require(:plugins_call_tool).permit(:targets_csv_file, :active, :title)
    end
  end
end

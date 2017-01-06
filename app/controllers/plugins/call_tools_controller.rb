# frozen_string_literal: true
module Plugins
  class CallToolsController < BaseController
    before_filter :find_call_tool, only: [:update, :delete_sound_clip]

    def update
      updater = ::CallTool::PluginUpdater.new(@call_tool, update_params)
      if updater.run
        respond_to do |format|
          format.js
        end
      else
        render json: { errors: updater.errors, name: :plugins_call_tool }, status: :unprocessable_entity
      end
    end

    def delete_sound_clip
      @call_tool.update(sound_clip: nil)

      respond_to do |format|
        format.js
      end
    end

    private

    def find_call_tool
      @call_tool = Plugins::CallTool.find(params[:id])
    end

    def update_params
      params.require(:plugins_call_tool).permit(:targets_csv_file, :active, :title, :sound_clip)
    end
  end
end

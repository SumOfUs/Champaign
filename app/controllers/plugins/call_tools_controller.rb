# frozen_string_literal: true
module Plugins
  class CallToolsController < BaseController
    def update_targets
      @call_tool = Plugins::CallTool.find(params[:id])
      @show_targets = true
      updater = ::CallTool::PluginUpdater.new(@call_tool, targets_params)
      if updater.run
        render template: 'plugins/call_tools/_target_form.slim', locals: { plugin: @call_tool }
      else
        render template: 'plugins/call_tools/_target_form.slim', locals: { plugin: @call_tool },
               status: :unprocessable_entity
      end
    end

    def update_sound_clip
      @call_tool = Plugins::CallTool.find(params[:id])
      updater = ::CallTool::PluginUpdater.new(@call_tool, sound_clip_params)
      if updater.run
        render '_sound_clip_form', locals: { plugin: @call_tool }
      else
        render '_sound_clip_form', locals: { plugin: @call_tool }, status: :unprocessable_entity
      end
    end

    def delete_sound_clip
      @call_tool = Plugins::CallTool.find(params[:id])
      key = params['role'] == 'main' ? :sound_clip : :menu_sound_clip
      @call_tool.update!(key => nil)
      render '_sound_clip_form', locals: { plugin: @call_tool }
    end

    private

    def update_params
      params.require(:plugins_call_tool).permit(:targets_csv_file, :active, :title, :sound_clip, :description)
    end

    def targets_params
      params[:plugins_call_tool]&.permit(:targets_csv_file) || {}
    end

    def sound_clip_params
      params[:plugins_call_tool]&.permit(:sound_clip, :menu_sound_clip) || {}
    end
  end
end

# frozen_string_literal: true

module Plugins
  class CallToolsController < BaseController
    # FIXME
    skip_before_action :verify_authenticity_token

    def update_targets
      @call_tool = Plugins::CallTool.find(params[:id])
      updater = ::CallTool::PluginUpdater.new(@call_tool, targets_params)
      status = updater.run ? :ok : :unprocessable_entity
      render template: 'plugins/call_tools/_target_form.slim',
             status: status,
             locals: { plugin: @call_tool },
             layout: false
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
      params.require(:plugins_call_tool).permit(
        :targets_csv_file, :active, :title, :sound_clip, :description, :caller_phone_number_id
      )
    end

    def targets_params
      params[:plugins_call_tool]&.permit(:targets_csv_file) || {}
    end

    def sound_clip_params
      params[:plugins_call_tool]&.permit(:sound_clip, :menu_sound_clip) || {}
    end
  end
end

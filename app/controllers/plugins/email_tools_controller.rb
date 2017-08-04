module Plugins
  class EmailToolsController < BaseController
    # FIXME
    skip_before_action :verify_authenticity_token

    def update_targets
      @email_tool = Plugins::EmailTool.find(params[:id])
      updater = ::EmailTool::PluginUpdater.new(@email_tool, targets_params)
      status = updater.run ? :ok : :unprocessable_entity
      render template: 'plugins/email_tools/_target_form.slim',
             status: status,
             locals: { plugin: @email_tool },
             layout: false
    end

    private

    def targets_params
      params[:plugins_email_tool]&.permit(:targets_csv_file) || {}
    end
  end
end

module Plugins
  class EmailToolsController < BaseController
    # FIXME
    skip_before_action :verify_authenticity_token

    def update_targets
      @email_tool = Plugins::EmailTool.find(params[:id])
      @targets_csv_text = targets_params[:targets_csv_text]

      updater = ::EmailTool::PluginUpdater.new(@email_tool, targets_params)
      status = if updater.run
                 flash.now[:success] = 'Targets have been updated successully'
                 :ok
               else
                 :unprocessable_entity
               end

      render template: 'plugins/email_tools/_target_form.slim',
             status: status,
             locals: { plugin: @email_tool },
             layout: false
    end

    private

    def targets_params
      params[:plugins_email_tool]&.permit(:targets_csv_file, :targets_csv_text) || {}
    end
  end
end

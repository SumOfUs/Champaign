# frozen_string_literal: true

class EmailTool::PluginUpdater
  def initialize(email_tool, params)
    @email_tool = email_tool
    @params = params.clone
    @targets_csv = @params.delete(:targets_csv_file)&.read
  end

  def run
    if @targets_csv.present?
      @params[:targets] = EmailTool::TargetsParser.parse_csv(@targets_csv)
    end
    @email_tool.update(@params)
  end

  def errors
    @email_tool.errors
  end
end

# frozen_string_literal: true
class CallTool::PluginUpdater
  def initialize(call_tool, params)
    @call_tool = call_tool
    @params    = params.clone
    @targets_csv = @params.delete(:targets_csv_file)&.read
  end

  def run
    @params[:targets] = parse_targets
    @call_tool.update(@params)
  end

  def errors
    @call_tool.errors
  end

  private

  def parse_targets
    if @targets_csv.present?
      CallTool::TargetsParser.parse_csv(@targets_csv)
    else
      []
    end
  end
end

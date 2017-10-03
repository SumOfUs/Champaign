# frozen_string_literal: true

class CallTool::PluginUpdater
  def initialize(call_tool, params)
    @call_tool = call_tool
    @params = params.clone
    @targets_csv = @params.delete(:targets_csv_file)&.read
  end

  def run
    if @targets_csv.present?
      @params[:targets] = CallTool::TargetsParser.parse_csv(@targets_csv.force_encoding(encoding))
    end
    @call_tool.update(@params)
  end

  def errors
    @call_tool.errors
  end

  private

  def encoding
    if @targets_csv.force_encoding(Encoding::UTF_8).valid_encoding?
      Encoding::UTF_8
    else
      Encoding::ISO_8859_15
    end
  end
end

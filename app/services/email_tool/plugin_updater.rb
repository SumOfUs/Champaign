# frozen_string_literal: true

class EmailTool::PluginUpdater
  def initialize(email_tool, params)
    @email_tool = email_tool
    @params = params.clone
  end

  def run
    targets_csv = @params.delete(:targets_csv_file)&.read ||
                  @params.delete(:targets_csv_text)
    if targets_csv.present?
      encoding = EncodingPicker.pick(targets_csv)
      @params[:targets] = EmailTool::TargetsParser.parse_csv(targets_csv.force_encoding(encoding))
    end
    @email_tool.update(@params)
  end

  def errors
    @email_tool.errors
  end
end

# frozen_string_literal: true

class CallTool::TargetsParser
  CSV_OPTIONS = {
    return_headers: false,
    headers: :first_row,
    header_converters: :symbol,
    converters: ->(o) { o.strip }
  }.freeze

  class << self
    def parse_csv(csv_string)
      targets = []
      CSV.parse(csv_string, CSV_OPTIONS) do |row|
        attrs = row.to_hash
        target = attrs.slice(*CallTool::Target::MAIN_ATTRS)
        fields = attrs.except(*CallTool::Target::MAIN_ATTRS)
        targets << CallTool::Target.new(target.merge(fields: fields))
      end
      targets
    end
  end
end

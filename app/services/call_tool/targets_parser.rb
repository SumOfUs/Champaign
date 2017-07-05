# frozen_string_literal: true

class CallTool::TargetsParser
  CSV_OPTIONS = {
    return_headers: false,
    headers: :first_row,
    header_converters: :symbol,
    converters: ->(o) { o.strip }
  }.freeze

  REQUIRED_FIELDS = %i[
    name
    phone_number
    country_name
    caller_id
  ].freeze

  class << self
    def parse_csv(csv_string)
      targets = []
      CSV.parse(csv_string, CSV_OPTIONS) do |row|
        data = row.to_hash
        target = data.slice(*REQUIRED_FIELDS).merge(fields: data.except(*REQUIRED_FIELDS))
        targets << CallTool::Target.new(target)
      end
      targets
    end
  end
end

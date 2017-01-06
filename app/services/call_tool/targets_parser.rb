# frozen_string_literal: true
class CallTool::TargetsParser
  REPEAT_PREVIOUS_ROW_SYMBOL = '``'
  CSV_OPTIONS = {
    return_headers: false,
    headers: :first_row,
    header_converters: ->(o) { o.strip },
    converters: ->(o) { o.strip }
  }.freeze

  class << self
    def parse_csv(csv_string)
      # Headers  ["country", "postal", "target phone", "target name", "target title"];
      targets = []
      previous_target = CallTool::Target.new

      CSV.parse(csv_string, CSV_OPTIONS) do |row|
        params = {
          country_name: new_target_value(previous_target.country_name, row['country']),
          postal_code:  new_target_value(previous_target.postal_code, row['postal']),
          phone_number: new_target_value(previous_target.phone_number, row['target phone']),
          name:         new_target_value(previous_target.name, row['target name']),
          title:        new_target_value(previous_target.title, row['target title'])
        }

        new_target = CallTool::Target.new(params)
        targets << new_target
        previous_target = new_target
      end
      targets
    end

    private

    def new_target_value(previous_value, new_row_value)
      if new_row_value.blank?
        nil
      elsif new_row_value == REPEAT_PREVIOUS_ROW_SYMBOL
        previous_value
      else
        new_row_value
      end
    end
  end
end

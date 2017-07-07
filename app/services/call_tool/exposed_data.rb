module CallTool
  class ExposedData
    attr_reader :query
    RELEVANT_ATTRIBUTES = %i[target_name target_title target_phone_number target_phone_extension checksum].freeze

    def initialize(plugin_data, query)
      @query = query
      @plugin_data = plugin_data
    end

    def to_h
      return @plugin_data unless encoded_target_valid?

      @plugin_data.map do |key, data|
        [key, data.merge(query.slice(*RELEVANT_ATTRIBUTES))]
      end.to_h
    end

    def encoded_target_valid?
      CallTool::ChecksumValidator.validate(@query[:target_phone_number], @query[:checksum])
    end
  end
end

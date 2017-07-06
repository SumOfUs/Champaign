module CallTool
  class ExposedData
    attr_reader :query

    def initialize(plugin_data, query, secret)
      @query = query
      @plugin_data = plugin_data
      @secret = secret
    end

    def to_h
      return @plugin_data unless encoded_target_valid?

      @plugin_data[:default].merge!(query.slice(:target_name, :target_number, :checksum))

      @plugin_data
    end

    def encoded_target_valid?
      return false if query[:checksum].blank?

      options = {
        name: query[:target_name],
        number: query[:target_number],
        checksum: query[:checksum],
        secret: @secret
      }

      CheckSumValidator.validate(options)
    end
  end
end

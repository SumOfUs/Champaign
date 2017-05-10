# frozen_string_literal: true

class PensionFundSuggestion
  class << self
    def create(name)
      opts = {
        table_name: 'PensionFundSuggestion',
        item: {
          CreatedAt: DateTime.now.to_s(:db),
          Name: name
        }
      }

      store.put_item(opts)
    end

    def store
      @dynamodb = Aws::DynamoDB::Client.new(region: Settings.aws_region)
    end
  end
end

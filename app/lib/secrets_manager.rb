# frozen_string_literal: true

require 'aws-sdk-secretsmanager'

module SecretsManager
  class << self
    # @param secret_id [String] - The secret ID to get the value for
    # @return [String] - The value of the stored secret
    def get_value(secret_id)
      puts 'Test Log'
      JSON.parse(secrets_manager.get_secret_value(
        secret_id: secret_name(secret_id)
      ).secret_string)
    rescue StandardError => e
      Rails.logger.error(
        "Error while trying to get secret #{secret_id} from AWS with error: #{e.message}."
      )
      throw e
    end

    private

    def secret_name(secret_id)
      if secret_id.include? '/'
        secret_id
      else
        [prefix, secret_id].compact.join('/')
      end
    end

    def secrets_manager
      Aws::SecretsManager::Client.new(region: Settings.aws_region)
    end

    def prefix
      Settings.aws_secrets_manager_prefix
    end
  end
end

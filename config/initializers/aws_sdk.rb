require 'aws-sdk-rails'

Aws.config.update({
                    region: Settings.aws_region,
                    credentials: Aws::Credentials.new(Settings.aws_access_key_id, Settings.aws_secret_access_key)
                  })

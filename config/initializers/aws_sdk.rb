# frozen_string_literal: true

require 'aws-sdk-rails'

Aws.config.update(region: Settings.aws_region)

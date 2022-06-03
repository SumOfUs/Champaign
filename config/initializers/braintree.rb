# frozen_string_literal: true

require './app/lib/secrets_manager'
braintree_secrets = SecretsManager.get_value('braintree') if Rails.env == 'production'

Braintree::Configuration.environment =  (Settings.braintree.environment || :sandbox).to_sym
Braintree::Configuration.logger      =  Logger.new('log/braintree.log')
Braintree::Configuration.merchant_id =  braintree_secrets.nil? ? Settings.braintree.merchant_id : braintree_secrets['merchantId'] # rubocop:disable Metrics/LineLength
Braintree::Configuration.public_key  =  braintree_secrets.nil? ? Settings.braintree.public_key : braintree_secrets['publicKey'] # rubocop:disable Metrics/LineLength
Braintree::Configuration.private_key =  braintree_secrets.nil? ? Settings.braintree.private_key : braintree_secrets['privateKey'] # rubocop:disable Metrics/LineLength

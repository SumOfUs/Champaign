# frozen_string_literal: true

require './app/lib/secrets_manager'
braintree_secrets = SecretsManager.get_value('braintree')

Braintree::Configuration.environment =  (Settings.braintree.environment || :sandbox).to_sym
Braintree::Configuration.logger      =  Logger.new('log/braintree.log')
Braintree::Configuration.merchant_id =  braintree_secrets['merchantId']
Braintree::Configuration.public_key  =  braintree_secrets['publicKey']
Braintree::Configuration.private_key =  braintree_secrets['privateKey']

# frozen_string_literal: true

Braintree::Configuration.environment =  (Settings.braintree.environment || :sandbox).to_sym
Braintree::Configuration.logger      =  Logger.new('log/braintree.log')
Braintree::Configuration.merchant_id =  Settings.braintree.merchant_id
Braintree::Configuration.public_key  =  Settings.braintree.public_key
Braintree::Configuration.private_key =  Settings.braintree.private_key

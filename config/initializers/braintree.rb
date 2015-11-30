Braintree::Configuration.environment = :sandbox
Braintree::Configuration.logger = Logger.new('log/braintree.log')
Braintree::Configuration.merchant_id = Settings.braintree_merchant_id
Braintree::Configuration.public_key = Settings.braintree_public_key
Braintree::Configuration.private_key = Settings.braintree_private_key

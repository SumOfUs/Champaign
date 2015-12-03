Braintree::Configuration.environment = :sandbox
Braintree::Configuration.logger = Logger.new('log/braintree.log')
# DEBUG:
puts "Debug Settings:"
p Settings
Braintree::Configuration.merchant_id = Settings.braintree.merchant_id
Braintree::Configuration.public_key = Settings.braintree.public_key
Braintree::Configuration.private_key = Settings.braintree.private_key

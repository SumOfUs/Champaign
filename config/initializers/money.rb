require 'money'
require 'money_oxr/bank'

Money.default_bank = MoneyOXR::Bank.new(
  app_id: Settings.oxr_app_id,
  cache_path: 'tmp/oxr.json',
  max_age: 86_400 # 24 hours
)

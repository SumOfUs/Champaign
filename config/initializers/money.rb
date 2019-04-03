require 'money'
require 'money_oxr/bank'

# Currency formatting depends on the locale, not the currency
Money.locale_backend = :i18n

Money.default_bank = MoneyOXR::Bank.new(
  app_id: Settings.oxr_app_id,
  cache_path: 'tmp/oxr.json',
  max_age: 86_400 # 24 hours
)

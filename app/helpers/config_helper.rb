# frozen_string_literal: true

module ConfigHelper
  def global_config
    config = {
      env: Rails.env.to_s,
      default_currency: Settings.default_currency,
      facebook: Settings.facebook.to_hash.slice(:pixel_id),
      recaptcha3: Settings.recaptcha3.to_hash.slice(:site_key),
      recaptcha2: Settings.recaptcha2.to_hash.slice(:site_key)
    }.deep_transform_keys! do |key|
      key.to_s.camelize(:lower)
    end
    return config unless Settings.end_of_year == true

    config.merge(
      eoyThermometer: eoy_thermometer_config,
      localPaymentMerchantAccountId: PaymentProcessor::Braintree::MerchantAccountSelector.for_currency('EUR')
    )
  end

  def eoy_thermometer_config
    # Actual EOY values
    start_date = Date.new(2020, 12, 1)
    end_date = Date.new(2021, 1, 1)
    # end of year goal in cents
    eoy_goal = 50_000_000

    # Values for testing on staging:
    # start_date = Date.new(2020, 10, 1)
    # end_date = Date.new(2021, 1, 1)
    # eoy_goal = 50_000_000

    total_donations = TransactionService.totals(start_date...end_date)
    goals = TransactionService.goals(eoy_goal)
    {
      meta: { start: start_date.to_s, end: end_date.to_s },
      data: {
        active: true,
        total_donations: total_donations,
        goals: goals,
        offset: 0,
        title: '',
        percentage: goals[:USD].zero? ? 0 : (total_donations[:USD] / goals[:USD] * 100)
      }
    }
  end
end

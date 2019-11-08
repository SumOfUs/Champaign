# frozen_string_literal: true

module ConfigHelper
  def global_config
    {
      env: Rails.env.to_s,
      default_currency: Settings.default_currency,
      facebook: Settings.facebook.to_hash.slice(:pixel_id),
      recaptcha3: Settings.recaptcha3.to_hash.slice(:site_key),
      recaptcha2: Settings.recaptcha2.to_hash.slice(:site_key),
      # this you can get from window.champaign.configuration
      eoy_thermometer: eoy_thermometer_config
    }.transform_keys! do |key|
      key.to_s.camelize(:lower)
    end
  end

  def eoy_thermometer_config
    # needs to have goals (hash with currencies as keys), percentage, total_donations (hash with currencies as keys)
    start_date = Date.new(2019, 11, 1)
    end_date = Date.new(2019, 12, 31)
    # end of year goal in cents
    eoy_goal = 60_000_000
    total_donations = TransactionService.totals(start_date...end_date)
    goals = TransactionService.goals(eoy_goal)
    {
      meta: { start: start_date.to_s, end: end_date.to_s },
      data: {
        active: true,
        total_donations: total_donations,
        goals: goals,
        offset: 0,
        # TODO: set title
        title: '',
        percentage: goals[:USD].zero? ? 0 : (total_donations[:USD] / goals[:USD] * 100)
      }
    }
  end
end

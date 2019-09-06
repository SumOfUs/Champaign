# frozen_string_literal: true

module ConfigHelper
  def global_config
    {
      env: Rails.env.to_s,
      default_currency: Settings.default_currency,
      facebook: Settings.facebook.to_hash.slice(:pixel_id),
      recaptcha3: Settings.recaptcha3.to_hash.slice(:site_key)
    }.deep_transform_keys! do |key|
      key.to_s.camelize(:lower)
    end
  end
end

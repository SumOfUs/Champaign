# frozen_string_literal: true

if Rails.env.production? && Settings.geocoder.host.present?
  Geocoder.configure(freegeoip: {
    host: Settings.geocoder.host
  })
end

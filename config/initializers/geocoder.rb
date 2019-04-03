# frozen_string_literal: true

if Rails.env.production?
  Geocoder.configure(freegeoip: {
    host: Settings.geocoder.host
  })
end

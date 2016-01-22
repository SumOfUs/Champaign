if Rails.env.production?
  Geocoder.configure(freegeoip: {
    host: Settings.geocoder.host
  })
end

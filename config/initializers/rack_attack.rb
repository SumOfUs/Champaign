class Rack::Attack
  # Braintree transactions
  %w[
    3.5.seconds
    7.1.hour
    20.24.hours
  ].each do |criteria|
    limit, period, unit = criteria.split('.')
    ip_key = "tx/ip/#{period}#{unit}"
    device_key = "tx/device/#{period}#{unit}"

    throttle(ip_key, limit: limit.to_i, period: period.to_i.send(unit)) { |req| transaction_rule(req) }
    throttle(device_key, limit: limit.to_i, period: period.to_i.send(unit)) { |req| device_rule(req) }
  end

  # Exponential throttling on actions endpoint:
  (1..5).reverse_each do |level|
    throttle("req/ip/#{level}", limit: (20 * level), period: (8**level).seconds) do |req|
      api_rule(req)
    end
  end

  # Block suspicious requests to frequently botted donations paths.
  # After 5 blocked requests in 24 hours, block all requests from that IP or device key.
  Rack::Attack.blocklist('fail2ban donationbots') do |req|
    # `filter` returns truthy value if request fails, or if it's from a previously banned IP
    # so the request is blocked
    Rack::Attack::Fail2Ban.filter("donationbots-ip-#{ip_key}",
                                  maxretry: 5,
                                  findtime: 24.hours,
                                  bantime: -1) do
      # The count for the IP is incremented if the return value is truthy
      req.path =~ %r{^/api/payment/braintree/pages/\d+/transaction} && req.post?
    end

    Rack::Attack::Fail2Ban.filter(
        "donationbots-device_key-#{device_key}",
        maxretry: 5,
        findtime: 24.hours,
        bantime: -1) do
      # The count for the device key is incremented if the return value is truthy
      req.path =~ %r{^/api/payment/braintree/pages/\d+/transaction} && req.post?
    end


  end

end

# Instrumentation and Logging
ActiveSupport::Notifications.subscribe('throttle.rack_attack') do |name, _start, _finish, _request_id, payload|
  req = payload[:request]
  ip = req.location.ip
  matched = req.env['rack.attack.matched']
  match_data = req.env['rack.attack.match_data']

  # if match_data[:count] == (match_data[:limit] + 1) && matched =~ %r{tx/ip/\dh}
  #   Rails.logger.info "[#{name}] #{ip} matched #{matched} and has been throttled for #{match_data[:period]} seconds"
  # end
  Rails.logger.info "[#{name}] #{ip} POST #{req.path}"
  Rails.logger.info "[#{name}] #{ip} matched #{matched} and has been throttled for #{match_data[:period]} seconds"
end

def api_rule(req)
  if req.path =~ %r{^/api/pages/} && req.post?
    req.location.ip unless req.env['warden'].user
  end
end

def device_rule(req)
  if req.path =~ %r{^/api/payment/braintree/pages/\d+/transaction} && req.post?
    unless req.env['warden'].user
      params = Rack::Utils.parse_nested_query req.env['rack.input'].string
      params.dig('device_data', 'device_session_id')
    end
  end
end

def transaction_rule(req)
  if req.path =~ %r{^/api/payment/braintree/pages/\d+/transaction} && req.post?
    req.location.ip unless req.env['warden'].user
  end
end

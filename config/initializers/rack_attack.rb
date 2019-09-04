class Rack::Attack
  # Braintree transactions
  %w[
    3.5.seconds
    5.20.seconds
    8.60.seconds
    15.10.minutes
    20.1.hour
    40.5.hours
    60.24.hours
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

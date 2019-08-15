class Rack::Attack
  # Braintree transactions
  throttle('tx/ip/1s', limit: 3, period: 5.seconds) { |req| transaction_rule(req) }
  throttle('tx/ip/20s', limit: 5, period: 20.seconds) { |req| transaction_rule(req) }
  throttle('tx/ip/1m', limit: 8, period: 60.seconds) { |req| transaction_rule(req) }
  throttle('tx/ip/10m', limit: 15, period: 10.minutes) { |req| transaction_rule(req) }
  throttle('tx/ip/1h', limit: 21, period: 1.hour) { |req| transaction_rule(req) }
  throttle('tx/ip/5h', limit: 41, period: 5.hours) { |req| transaction_rule(req) }
  throttle('tx/ip/1d', limit: 61, period: 24.hours) { |req| transaction_rule(req) }

  # Exponential throttling on all API endpoints:
  (1..5).each do |level|
    throttle("req/ip/#{level}", limit: (20 * level), period: (8**level).seconds) do |req|
      api_rule(req)
    end
  end
end

# Instrumentation and Logging
ActiveSupport::Notifications.subscribe('throttle.rack_attack') do |name, _start, _finish, _request_id, payload|
  req = payload[:request]
  ip = req.location.ip
  match_data = req.env['rack.attack.match_data']
  if match_data[:count] == match_data[:limit] && matched == 'tx/ip/1d'
    Rails.logger.info "[#{name}] #{ip} matched tx/ip/1d and has been throttled for 24 hours"
  end
end

def api_rule(req)
  if req.path =~ %r{^/api/} && req.post?
    req.location.ip unless req.env['warden'].user
  end
end

def transaction_rule(req)
  if req.path =~ %r{^/api/payment/braintree} && req.post?
    req.location.ip unless req.env['warden'].user
  end
end

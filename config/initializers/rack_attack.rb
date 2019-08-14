class Rack::Attack
  (1..5).each do |level|
    throttle("req/ip/#{level}", limit: (20 * level), period: (8**level).seconds) do |req|
      if req.path =~ %r{^/api/} && req.post?
        req.env.fetch('HTTP_X_FORWARDED_FOR', req.ip).split(',')[0] unless req.env['warden'].user
      end
    end
  end
end

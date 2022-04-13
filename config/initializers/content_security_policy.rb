Rails.application.config.content_security_policy do |policy|
  policy.frame_ancestors :self, 'pronto.sumofus.org', 'apiboficial.org'
end

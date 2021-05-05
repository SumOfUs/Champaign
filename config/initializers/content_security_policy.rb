Rails.application.config.content_security_policy do |policy|
  policy.frame_ancestors :self, 'sumofus.org'
end

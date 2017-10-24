# frozen_string_literal: true

puts 'Seeding...'

# Forms
%w[en fr de].each do |locale|
  language_names = { en: 'English', de: 'German', fr: 'French' }
  if Language.where(code: locale).blank?
    Language.create(code: locale, name: language_names[locale.to_sym])
  end
  DefaultFormBuilder.find_or_create(locale: locale)
end

email = Settings.default_admin_email || 'admin@test.com'
if User.where(email: email).blank?
  if Rails.env.development? || Settings.default_admin_password.present?
    pwd = Settings.default_admin_password || '12345678'
    User.create(email: email, password: pwd)
  end
end

# Liquid Markup
LiquidMarkupSeeder.seed

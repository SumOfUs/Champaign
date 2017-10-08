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

if Rails.env.development? && User.where(email: 'admin@test.com').blank?
  User.create(email: 'admin@test.com', password: 12_345_678)
end

# Liquid Markup
LiquidMarkupSeeder.seed

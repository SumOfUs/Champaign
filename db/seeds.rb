# frozen_string_literal: true
puts 'Seeding...'

# Forms
%w(en fr de).each do |locale|
  DefaultFormBuilder.create(locale: locale)
end

# Liquid Markup
LiquidMarkupSeeder.seed

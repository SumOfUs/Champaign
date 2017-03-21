# frozen_string_literal: true
require './lib/liquid_markup_seeder'

namespace :champaign do
  desc 'Seed database with liquid markup for partials and templates'
  task seed_liquid: :environment do
    puts 'Starting Liquid Markup Seeder...'
    puts "HERE IS THE HOST: #{ENV['CACHE_HOST']}"
    puts "HERE IS THE ENV: #{ENV.to_json}"
    puts "HERE IS Settings: #{Settings.to_json}"
    LiquidMarkupSeeder.seed

    puts 'Seeding is done.'
  end
end

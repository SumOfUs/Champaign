# frozen_string_literal: true

require './app/lib/liquid_markup_seeder'

namespace :champaign do
  desc 'Seed database with liquid markup for partials and templates'
  task seed_liquid: :environment do
    puts 'Starting Liquid Markup Seeder...'

    LiquidMarkupSeeder.seed

    puts 'Seeding is done.'
  end
end

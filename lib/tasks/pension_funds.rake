# frozen_string_literal: true

namespace :pension_funds do
  desc 'Seed database with pension funds data stored in fixtures json files'
  task seed_data: :environment do
    puts 'Starting Seed ...'
    PensionFundSeeder.seed
    puts 'Seeding is done.'
  end
end

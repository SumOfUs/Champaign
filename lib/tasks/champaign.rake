require './lib/liquid_markup_seeder'

namespace :champaign do
  desc "Set plugins to active"
  task activate_plugins: :environment do
    puts "Starting update..."

    Plugins.registered.each do |plugin|
      plugin.all.each{|pl| pl.update({active: true}) }
    end

    puts "Update is done."
  end

  desc "Seed database with liquid markup for partials and templates"
  task seed_liquid: :environment do
    puts "Starting Liquid Markup Seeder..."

    LiquidMarkupSeeder.seed

    puts "Seeding is done."
  end

  desc "Seed database with languages"
  task seed_languages: :environment do
    #
    # Presently only seeds with English. Move to a dedicated class
    # when list of languages grows.
    #
    languages = [{code: 'EN', name: 'English'}]

    languages.each do |lang|
      unless Language.exists?(lang)
        puts "Creating #{lang[:name]}"
        Language.create!(lang)
      end
    end
  end
end

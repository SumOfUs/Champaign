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

  desc "ONE-OFF task for updating plugins to work with polymorphic forms"
  task make_forms_poly: :environment do
    [Plugins::Fundraiser, Plugins::Petition].each do |plugin_class|
      plugin_class.all.each do |plugin|
        form = Form.find(plugin.form_id)

        if form
          puts "Updating form #{form.id}"
          form.update(formable: plugin)
        end
      end
    end
  end
end

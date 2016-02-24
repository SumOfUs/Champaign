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

  desc "Seeds database with tags for campaigners"
  task seed_campaigner_tags: :environment do
    puts "Adding campaigner tags..."

    campaigners=[
      { name: "JonL", actionkit_uri: "/rest/v1/tag/1015/" },
      { name: "KatherineT", actionkit_uri: "/rest/v1/tag/818/" },
      { name: "LedysS", actionkit_uri: "/rest/v1/tag/992/" },
      { name: "NicoleC", actionkit_uri: "/rest/v1/tag/1197/" },
      { name: "EmmaP", actionkit_uri: "/rest/v1/tag/1044/" },
      { name: "LizM", actionkit_uri: "/rest/v1/tag/1004/" },
      { name: "PaulF", actionkit_uri: "/rest/v1/tag/821/" },
      { name: "AngusW", actionkit_uri: "/rest/v1/tag/816/" },
      { name: "MartinC", actionkit_uri: "/rest/v1/tag/878/" },
      { name: "AnneI", actionkit_uri: "/rest/v1/tag/1018/" },
      { name: "WiebkeS", actionkit_uri: "/rest/v1/tag/1200/" },
      { name: "FatahS", actionkit_uri: "/rest/v1/tag/1102/" },
      { name: "NabilB", actionkit_uri: "/rest/v1/tag/1465/" },
      { name: "SondhyaG", actionkit_uri: "/rest/v1/tag/1651/" },
      { name: "HannaT", actionkit_uri: "/rest/v1/tag/817/" },
      { name: "RosaK", actionkit_uri: "/rest/v1/tag/1422/" },
      { name: "EoinD", actionkit_uri: "/rest/v1/tag/1112/" },
      { name: "HannahL", actionkit_uri: "/rest/v1/tag/982/" },
      { name: "StevenB", actionkit_uri: "/rest/v1/tag/911/" },
      { name: "MarkTP", actionkit_uri: "/rest/v1/tag/1019/" },
      { name: "BexS", actionkit_uri: "/rest/v1/tag/1388/" },
      { name: "MichaelS", actionkit_uri: "/rest/v1/tag/1160/" },
      { name: "DeborahL", actionkit_uri: "/rest/v1/tag/1661/" },
      { name: "KatieF", actionkit_uri: "/rest/v1/tag/1662/" }]

    campaigners.each do |campaigner|
      # Find the first tag named after the campaigner, or create a new one with the campaigner's name.
      Tag.create_with(actionkit_uri: campaigner[:actionkit_uri]).find_or_create_by(name: campaigner[:name])
    end
    puts "Finished adding campaigner tags."
  end

  desc 'Import legacy actions into your database from a specified file'
  task seed_legacy_actions: :environment do
    if ARGV[1].nil?
      abort('Requires a valid path to a file containing the legacy actions to seed.')
    end

    file_handle = File.open(ARGV[1], 'r')
    data = file_handle.read
    file_handle.close

    parsed_data = JSON.load data
    count = 0
    parsed_data.each_pair do |k, v|
      count += 1
    end

    p count
  end
end

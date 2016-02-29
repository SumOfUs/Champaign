require 'open-uri'

namespace :sumofus do
  desc 'Import legacy actions into your database from a specified file'
  task seed_legacy_actions: :environment do
    if ARGV[1].nil?
      abort('Requires a valid url to a file containing the legacy actions to seed.')
    end

    if ARGV[2].nil?
      abort('Requires a valid url to a file containing a default header image to attach to the page.')
    end

    file_handle = open(ARGV[1])
    data = file_handle.read
    file_handle.close

    image_handle = open(ARGV[2])

    parsed_data = JSON.load data
    count = 0
    layout_id = LiquidLayout.where(title: 'Petition With Small Image').first.id
    parsed_data.each_pair do |k, entry|
      count +=1
      title = entry['title'].blank? ? entry['petition_ask'] : entry['title']
      page = Page.find_or_create_by!(title: title, liquid_layout_id: layout_id)
      page.content = entry['page_content'].gsub(/(?:\n\r?|\r\n?)/, '<br>')
      Page.reset_counters(page.id, :actions)
      Page.update_counters(page.id, action_count: entry['signature_count'])
      page.language_id = Language.where(code: entry['language']).first.id
      page.active = true
      page.slug = entry['slug']
      page.save
      thermometer = Plugins::Thermometer.where(page_id: page.id).first
      thermometer.goal = entry['thermometer_target']
      thermometer.save
      petition_form = Plugins::Petition.where(page_id: page.id).first
      petition_form.description = entry['petition_ask'].gsub('"', '').gsub('Petition Text:', '')
      petition_form.target = entry['petition_target'].gsub(/Sign our petition to /i, '').gsub(/Sign the petition to /, '').gsub(/:/, '')
      petition_form.save
      if page.images.count == 0
        page.images.create(content: image_handle)
      end

    end

    image_handle.close

    p "#{count} pages added to the database"
  end
end

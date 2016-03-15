require 'open-uri'

namespace :sumofus do
  desc 'Import legacy actions into your database from a specified file'
  task :seed_legacy_actions, [:action_file, :page_img_file, :follow_img_file] => :environment do |task, args|

    if args[:action_file].blank?
      abort('Requires a valid url to a file containing the legacy actions to seed.')
    else
      page_image_handle = open(args[:page_img_file])
    end

    if args[:page_img_file].blank?
      abort('Requires a valid url to a file containing a default header image to attach to the page.')
    else
      puts "Loading page data"
      page_data_handle = open(args[:action_file])
      page_data = JSON.load(page_data_handle.read)
      page_data_handle.close
      puts "Page data loaded"
    end

    if args[:follow_img_file].blank?
      follow_image_handle = open(args[:page_img_file])
    else
      follow_image_handle = open(args[:follow_img_file])
    end

    def create_post_action_pages(layout_id, image_handle)
      pages = {}
      ['en', 'fr', 'de'].map do |locale|
        page = Page.find_or_initialize_by(title: I18n.t('fundraiser.generic.title', locale: locale))
        page.liquid_layout_id = layout_id
        page.language_id = language_ids[locale]
        page.content = I18n.t('fundraiser.generic.body', locale: locale)
        page.save!
        page.images.create!(content: image_handle) if page.images.empty?
        pages[locale] = page
      end
      pages
    end

    def manage_newlines(content)
      content.
        gsub(/(?:\n\r?|\r\n?)/, '<br>').
        gsub(/<br *\/*>/, '<br>').
        gsub(/<div><br>\t&nbsp;<\/div>/, '<br>').
        gsub(/(<br>)*\s*<\/p>\s*(<br>)*\s*<p>\s*(<br>)*/, '</p><br><p>').
        gsub(/(<br>)*\s*<\/div>\s*(<br>)*\s*<div>\s*(<br>)*/, '</p><br><p>').
        gsub(/(\s*<br>\s*){3,}/, '<br><br>')
    end

    def language_ids
      return @language_ids unless @language_ids.blank?
      @language_ids = {}
      Language.all.each do |l|
        @language_ids[l.code] = l.id
      end
      @language_ids
    end

    def clean_title(entry)
      title = entry['title'].blank? ? entry['petition_ask'] : entry['title']
      title.chomp(' ').chomp('!').chomp('.')
    end

    def duplicate_titles(titles)
      titles.map do |title, variations|
        variations.size > 1 ? title : nil
      end.compact
    end

    def unique_titles(page_data)
      titles = Hash.new({})
      # byebug
      page_data.each_pair do |k, entry|
        title = clean_title(entry)
        slug = entry['slug']
        case titles[title].size
        when 1
          titles[title][slug] = "#{title} now"
        when 2
          titles[title][slug] = "#{title} now!"
        when 3
          titles[title][slug] = "#{title} today"
        else # includes 0 case
          titles[title] = {}
          titles[title][slug] = title
        end
      end
      titles
    end

    count, existing_image = 0, nil
    petition_layout_id = LiquidLayout.where(title: 'Petition With Small Image').first.id
    fundraiser_layout_id = LiquidLayout.where(title: 'Fundraiser With Large Image').first.id

    post_action_pages = create_post_action_pages(fundraiser_layout_id, follow_image_handle)
    titles = unique_titles(page_data)

    duplicate_titles(titles).each do |title|
      Page.where(title: title).each do |p|
        p.update_attributes(title: titles[title][p.slug])
      end
    end

    page_data.each_pair do |k, entry|
      page = Page.find_or_initialize_by(slug: entry['slug'], liquid_layout_id: petition_layout_id)
      page.content = manage_newlines(entry['page_content'])
      page.language_id = Language.where(code: entry['language']).first.id
      page.active = true
      page.title = titles[clean_title(entry)][entry['slug']]
      page.follow_up_plan = :with_page
      page.follow_up_page = post_action_pages[entry['language']]
      puts "Adding page \"#{page.title}\" at <#{page.slug}>"
      page.save!
      Page.reset_counters(page.id, :actions)
      Page.update_counters(page.id, action_count: entry['signature_count'])
      thermometer = Plugins::Thermometer.where(page_id: page.id).first
      thermometer.goal = entry['thermometer_target']
      thermometer.save!
      petition = Plugins::Petition.where(page_id: page.id).first
      petition.description = entry['petition_ask'].gsub('"', '').gsub('Petition Text:', '')
      petition.target = entry['petition_target'].gsub(/Sign our petition to /i, '').gsub(/Sign the petition to /, '').gsub(/:/, '')
      petition.save!
      if page.images.count == 0
        if existing_image.blank?
          existing_image = page.images.create(content: page_image_handle)
        else
          Image.new(page: page, content: existing_image.content)
        end
      end
      count +=1
    end

    follow_image_handle.close if follow_image_handle != page_image_handle
    page_image_handle.close

    puts "#{count} pages added to the database"
  end
end

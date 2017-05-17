# frozen_string_literal: true
require 'open-uri'

namespace :sumofus do
  desc 'Import legacy actions into your database from a specified file'

  def legacy_tag
    # the actionkit_uri still needs to be confirmed
    return @tag unless @tag.blank?
    @tag = Tag.find_or_create_by(name: 'Actionsweet_Legacy')
    @tag.update_attributes(actionkit_uri: '/rest/v1/tag/1693/')
    @tag
  end

  task :check_legacy_actions, [:action_file] => :environment do |_task, args|
    if args[:action_file].blank?
      abort('Requires a valid url to a file containing the legacy actions to seed.')
    else
      puts 'Loading page data'
      page_data_handle = open(args[:action_file])
      page_data = JSON.parse(page_data_handle.read)
      page_data_handle.close
      puts 'Page data loaded'
    end

    puts 'Errors listed below, empty means no errors:'

    %w(en fr de).map do |locale|
      expected_title = I18n.t('fundraiser.generic.title', locale: locale)
      page = Page.find_by(title: expected_title)
      if page.blank?
        puts "Missing follow-up page for #{locale} (expected title: #{expected_title})"
      else
        if page.try(:language).try(:code) != locale
          puts "Follow-up for #{locale} has language #{page.try(:language).try(:code)}"
        end
        form = page.plugins.select { |p| p.class.name == 'Plugins::Fundraiser' }.first.form
        expected_form_name = "Basic (#{locale.upcase})"
        if form.name != expected_form_name
          puts "Follow-up for #{locale} has form #{form.name}, should be #{expected_form_name}"
        end
      end
    end

    page_data.each_pair do |_k, entry|
      begin
        # check existence, images, and language
        page = Page.find(entry['slug']) # raises if not found
        puts "Page at <#{entry['slug']}> has no image" if page.images.empty?
        unless page.language.code.to_s.casecmp(entry['language'].to_s.downcase).zero?
          puts "Page at <#{entry['slug']}> has language '#{page.language.code}', should be '#{entry['language']}'"
        end

        # check form
        form = page.plugins.select { |p| p.class.name == 'Plugins::Petition' }.first.form
        expected_form_name = "Basic (#{entry['language'].upcase})"
        if form.name != expected_form_name
          puts "Page at <#{entry['slug']}> has form #{form.name}, should be #{expected_form_name}"
        end

        # check follow-up
        if page.follow_up_plan.to_sym != :with_page
          puts "Page at <#{entry['slug']}> has follow_up_plan #{page.follow_up_plan}, should be with_page"
        end
        follow_title = page.follow_up_page.try(:title)
        expected_title = I18n.t('fundraiser.generic.title', locale: entry['language'])
        if follow_title != expected_title
          puts "Page at <#{entry['slug']}> has follow_up page with title #{follow_title}, should be #{expected_title}"
        end

        # check that it has the legacy tag
        relevant_tags = page.tags.select { |t| t.id == legacy_tag.id }
        if relevant_tags != [legacy_tag]
          puts "Page at <#{entry['slug']}> has tags #{page.tags.map(&:attributes)}, should include #{legacy_tag.attributes}"
        end
      rescue ActiveRecord::RecordNotFound
        puts "Page is missing: <#{entry['slug']}> with expected title \"#{entry['title']}\""
      end
    end
  end

  task :seed_legacy_actions, [:action_file, :page_img_file, :follow_img_file] => :environment do |_task, args|
    if args[:page_img_file].blank?
      abort('Requires a valid url to a file containing a default header image to attach to the page.')
    else
      page_image_handle = open(args[:page_img_file])
    end

    if args[:action_file].blank?
      abort('Requires a valid url to a file containing the legacy actions to seed.')
    else
      puts 'Loading page data'
      page_data_handle = open(args[:action_file])
      page_data = JSON.parse(page_data_handle.read)
      page_data_handle.close
      puts 'Page data loaded'
    end

    follow_image_handle = if args[:follow_img_file].blank?
                            open(args[:page_img_file])
                          else
                            open(args[:follow_img_file])
                          end

    def create_post_action_pages(layout_id, image_handle)
      pages = {}
      %w(en fr de).map do |locale|
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
      content
        .gsub(/(?:\n\r?|\r\n?)/, '<br>')
        .gsub(%r{<br *\/*>}, '<br>')
        .gsub(%r{<div><br>\t&nbsp;<\/div>}, '<br>')
        .gsub(%r{(<br>)*\s*<\/p>\s*(<br>)*\s*<p>\s*(<br>)*}, '</p><br><p>')
        .gsub(%r{(<br>)*\s*<\/div>\s*(<br>)*\s*<div>\s*(<br>)*}, '</p><br><p>')
        .gsub(/(\s*<br>\s*){3,}/, '<br><br>')
    end

    def language_ids
      @language_ids ||= Language.all.pluck(:code, :id).to_h
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
      page_data.each_pair do |_k, entry|
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

    pages_before = Page.count
    start_timestamp = Time.now

    existing_image = nil
    petition_layout = LiquidLayout.where(title: 'Petition With Small Image').first
    fundraiser_layout = LiquidLayout.where(title: 'Fundraiser With Large Image').first

    post_action_pages = create_post_action_pages(fundraiser_layout.id, follow_image_handle)
    titles = unique_titles(page_data)

    duplicate_titles(titles).each do |title|
      Page.where(title: title).each do |p|
        p.update_attributes(title: titles[title][p.slug])
      end
    end

    page_data.each_pair do |_k, entry|
      page = Page.find_or_initialize_by(slug: entry['slug'], liquid_layout_id: petition_layout.id)
      page.content = manage_newlines(entry['page_content'])
      page.language_id = language_ids[entry['language']]
      page.active = true
      page.title = titles[clean_title(entry)][entry['slug']]
      page.follow_up_plan = :with_page
      page.follow_up_page = post_action_pages[entry['language']]
      page.tags += [legacy_tag] unless page.tags.include? legacy_tag
      puts "Processing page \"#{page.title}\" at <#{page.slug}>"
      page.save!

      # update plugins
      page.plugins.map(&:destroy)
      PagePluginSwitcher.new(page).switch(petition_layout)

      Page.reset_counters(page.id, :actions)
      Page.update_counters(page.id, action_count: entry['signature_count'])
      thermometer = Plugins::Thermometer.where(page_id: page.id).first
      thermometer.goal = entry['thermometer_target']
      thermometer.save!
      petition = Plugins::Petition.where(page_id: page.id).first
      petition.description = entry['petition_ask'].delete('"').gsub('Petition Text:', '')
      petition.target = entry['petition_target'].gsub(/Sign our petition to /i, '').gsub(/Sign the petition to /, '').delete(':')
      petition.save!
      next unless page.images.count.zero?
      if existing_image.blank?
        existing_image = page.images.create(content: page_image_handle)
      else
        Image.create(page: page, content: existing_image.content)
      end
    end

    follow_image_handle.close if follow_image_handle != page_image_handle
    page_image_handle.close

    updated_count = Page.where('updated_at > ?', start_timestamp).where('created_at <= ?', start_timestamp).size
    created_count = Page.count - pages_before

    puts "#{created_count} pages added, #{updated_count} pages updated, #{page_data.size - updated_count - created_count} skipped"
  end
end

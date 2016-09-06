namespace :action_kit do
  task :import_languages => :environment do
    puts "Importing languages from ActionKit"
    response = ActionKitConnector.client.list_languages

    if !response.success?
      raise "Error connecting to ActionKit: #{response.inspect}"
    end

    response.parsed_response['objects'].each do |object|
      Language.create!(code: object['iso_code'], name: object['name'], actionkit_uri: object['resource_uri'])
    end
  end

  task :import_tags => :environment do
    puts "Importing tags from ActionKit"
    pages = ActionKitConnector.client.list_tags(page:true)

    pages.each_with_index do |response, index|
      puts "Importing batch ##{index}"
      if !response.success?
        raise "Error connecting to ActionKit: #{response.inspect}"
      end

      response.parsed_response['objects'].each do |object|
        tag = Tag.create name: object['name'], actionkit_uri: object['resource_uri']
        puts "Skipping Tag: #{tag.name}, #{tag.actionkit_uri}" if !tag.persisted?
      end
    end
  end
end

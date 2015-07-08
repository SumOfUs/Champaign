require_relative '../config/load_env'
require_relative '../lib/crm_page'
require 'json'

class ActionkitPageParser
  def initialize
    @base_url = ENV['ACTIONKIT_BASE_URL']
  end

  def parse_from_message(message)
    # Parse the text-based message here from RabbitMQ
  end

  def parse_from_actionkit(ak_json)
    # Parse the AK JSON here to create a new page object.
    parsed_json = JSON.parse(ak_json, quirks_mode: true)
    page = CrmPage.new parsed_json['id'], @base_url
    page.language = parsed_json['language']
    page.resource_uri = parsed_json['resource_uri']
    page.type = parsed_json['type']
    page.name = parsed_json['name']
    page.status = parsed_json['status']
    page.hidden = parsed_json['hidden']
    page.title = parsed_json['title']
    page
  end

  def parse_boolean(string_to_parse)

  end
end

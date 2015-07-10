require_relative '../config/load_env'
require_relative '../lib/crm_page'
require 'json'

class ActionkitPageParser
  def initialize
    @base_url = ENV['ACTIONKIT_BASE_URL']
    @widget_to_page_types = {petition: 'Petition', donation: 'Donation'}
  end

  def parse_from_message(message)
    parsed_json = JSON.parse(message)
    page = CrmPage.new
    page.base_url = @base_url

    # We need to create CRM pages for each widget type that demands them, which might
    # be a lot.
    parsed_page = parsed_json['page']
    widgets = parsed_page['widgets']
    created_pages = []
    if widgets
      widgets.each do |widget|
        if @widget_to_page_types[widget['widget_type'].to_sym]
          page = CrmPage.new title: parsed_page['title'], name: "#{parsed_page['slug']}-#{widget['widget_type'].to_s}",
                             type: @widget_to_page_types[widget['widget_type'].to_sym], hidden: false,
                             language: parsed_page['language']

          if parsed_page['active']
            page.status = 'active'
          else
            page.status = 'inactive'
          end
          created_pages.push page
        end
      end
    end
    created_pages
  end

  def parse_from_actionkit(ak_json)
    # Parse the AK JSON here to create a new page object.
    # The expectation is that we'll only get one page here.

    # We test for the existence of a hash because honestly,
    # if you have a bunch of pages that you want to turn
    # into objects, I don't expect you to split out
    # the JSON into individual strings. Just parse it
    # then send it to us as a hash.
    if ak_json.is_a? Hash
      parsed_json = ak_json
    else
      parsed_json = JSON.parse(ak_json)
    end

    if parsed_json['id']
      parsed_json['crm_id'] = parsed_json['id']
    end

    CrmPage.new parsed_json
  end
end

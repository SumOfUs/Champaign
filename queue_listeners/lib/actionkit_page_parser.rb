require_relative '../config/load_env'
require_relative '../lib/crm_page'
require 'json'

class ActionkitPageParser
  BASE_URL = ENV['ACTIONKIT_BASE_URL']
  WIDGET_TO_PAGE_TYPES = {petition: 'Petition', donation: 'Donation'}

  def self.parse_from_message(message)
    MessageQueueParser.new(message).parse_from_message
  end

  def self.parse_from_actionkit(message)
    ActionKitParser.new(message).parse_from_actionkit
  end

  private
  class MessageQueueParser
    def initialize(message)
      @parsed_message = JSON.parse message
    end

    def relevant_widgets(widgets)
      widgets.select { |widget| is_relevant?(widget) }
    end

    def is_relevant?(widget)
      !!WIDGET_TO_PAGE_TYPES[widget['widget_type'].to_sym]
    end

    def parse_from_message
      # We need to create CRM pages for each widget type that demands them, which might
      # be a lot or it might be none.
      parsed_page = @parsed_message['page']
      widgets = parsed_page['widgets']
      created_pages = []
      if widgets
        self.relevant_widgets(widgets).each do |widget|
          created_pages << create_page_for_widget(parsed_page, widget)
        end
      end
      created_pages
    end

    def create_page_for_widget(parsed_page, widget)
      CrmPage.new title: parsed_page['title'], name: "#{parsed_page['slug']}-#{widget['widget_type'].to_s}",
                  type: WIDGET_TO_PAGE_TYPES[widget['widget_type'].to_sym], hidden: false,
                  language: parsed_page['language']
    end
  end

  class ActionKitParser
    def initialize(message)
      if message.is_a? Hash
        @parsed_json = message
      else
        @parsed_json = JSON.parse(message)
      end
    end

    def parse_from_actionkit
      # Parse the AK JSON here to create a new page object.
      # The expectation is that we'll only get one page here.

      # We test for the existence of a hash because honestly,
      # if you have a bunch of pages that you want to turn
      # into objects, I don't expect you to split out
      # the JSON into individual strings. Just parse it
      # then send it to us as a hash.
      if @parsed_json['id']
        @parsed_json['crm_id'] = @parsed_json['id']
      end

      CrmPage.new @parsed_json
    end
  end
end

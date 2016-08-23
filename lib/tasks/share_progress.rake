# frozen_string_literal: true
namespace :share_progress do
  desc 'Get button analytics'
  task analytics: :environment do
    require 'net/http'
    require 'uri'

    puts 'Fetching data...'

    uri = 'http://run.shareprogress.org/api/v1/buttons/analytics'
    uri = URI.parse(uri)

    Share::Button.all.each do |button|
      response = Net::HTTP.post_form(uri, key: Settings.share_progress_api_key, id: button.sp_id)
      button.update(analytics: response.body)
    end

    puts 'Fetching has completed.'
  end
end

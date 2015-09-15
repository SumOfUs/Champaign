namespace :share_progress do

  desc "Get button analytics"
  task analytics: :environment do
    require "net/http"
    require "uri"

    puts "Fetching data..."

    Share::Button.all.each do |button|
      uri = 'http://run.shareprogress.org/api/v1/buttons/analytics'
      uri = URI.parse(uri)

      response = Net::HTTP.post_form(uri, {key: ENV['SHARE_PROGRESS_API_KEY'], id: button.sp_id})
      button.update(analytics: response.body )
    end

    puts "Fetching has completed."
  end
end

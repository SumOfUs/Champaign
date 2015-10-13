module ActionKit
  module Client
    extend self
    def client(verb, path, params)
      Typhoeus::Request.send(
        verb,
        "https://act.sumofus.org/rest/v1/#{path}/",
        { userpwd: "#{ENV['AK_USERNAME']}:#{ENV['AK_PASSWORD']}" }.merge(params)
      )
    end

    def get(path, params)
      client('get', path, params)
    end
  end
end


module ActionKit
  module Client
    extend self
    def client(verb, path, params)
      Typhoeus::Request.send(
        verb,
        "#{Settings.ak_api_url}/#{path}/",
        { userpwd: "#{Settings.ak_username}:#{Settings.ak_password}" }.merge(params)
      )
    end

    def get(path, params)
      client('get', path, params)
    end
  end
end


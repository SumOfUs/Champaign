module ActionKit
  module Client
    extend self

    HOST = 'https://act.sumofus.org/rest/v1'

    def client(verb, path, params)
      Typhoeus::Request.send(
        verb,
        URI.join(HOST, '/rest/v1/', "#{path}/"),
        { userpwd: "#{Settings.ak_username}:#{Settings.ak_password}" }.merge(params)
      )
    end

    def get(path, params)
      client('get', path, params)
    end
  end
end


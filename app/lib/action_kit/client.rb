# frozen_string_literal: true

require 'httparty'

module ActionKit
  module Client
    def client(verb, path, params)
      HTTParty.send(
        verb,
        "#{Settings.ak_api_url}/#{path}/",
        query: params[:params],
        basic_auth: auth
      )
    end

    def get(path, params)
      client('get', path, params)
    end

    def configured?
      Settings.ak_api_url.present? &&
        Settings.ak_username.present? &&
        Settings.ak_password.present?
    end

    private

    def auth
      {
        username: Settings.ak_username,
        password: Settings.ak_password
      }
    end

    module_function :client, :get, :configured?, :auth
  end
end

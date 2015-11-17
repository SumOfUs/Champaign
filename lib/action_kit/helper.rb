module ActionKit
  module Helper
    extend self

    def check_petition_name_is_available(name)
      resp = ActionKit::Client.get('petitionpage', params: {_limit: 1, name: name})

      if resp.response_code == 200
        { valid: JSON.parse(resp.response_body)['meta']['total_count'] == 0, response: JSON.parse(resp.response_body)}
      else
        { valid: false, response: resp }
      end
    end
  end
end


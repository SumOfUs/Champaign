# frozen_string_literal: true

module ActionKit
  module Helper
    def check_petition_name_is_available(name)
      return true unless ActionKit::Client.configured?

      resp = ActionKit::Client.get('petitionpage', params: { _limit: 1, name: name })
      if resp.code == 200
        (JSON.parse(resp.body)['meta']['total_count']).zero?
      else
        false
      end
    end

    module_function :check_petition_name_is_available
  end
end

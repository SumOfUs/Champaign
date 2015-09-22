require 'typhoeus'

class ShareProgress::Button
  BUTTON_ENDPOINT = 'https://run.shareprogress.org/api/v1/buttons/update'
  API_KEY= ENV['SHARE_PROGRESS_API_KEY']

  def initialize(options)
    @options = options
  end

  def save
    resp = Typhoeus.post(BUTTON_ENDPOINT, body: opts.deep_stringify_keys)
    OpenStruct.new( JSON.parse(resp.body)['response'][0] )
  end

  def opts
    @options.merge(key: API_KEY)
  end
end


class Pronto
  class PathMatcher
    PATTERN = %r{^((?:/a/)(?<Q>[\w-]+)(?:/?)(?:(\?.*)*))$}.freeze

    def self.match(path)
      match = PATTERN.match(path)
      return match[1] if match
    end
  end

  def initialize(app)
    @app = app
  end

  def call(env)
    @status, @headers, @response = @app.call(env)
    req = Rack::Request.new(env)

    path_match = PathMatcher.match(req.path)

    if path_match
      page = Page.find_by(slug: path_match)

      if page.language_code == 'en' && page.petition_page?
        location = "#{Settings.pronto.domain}/#{req.fullpath}"
        return [301, { 'Location' => location, 'Content-Type' => 'text/html', 'Content-Length' => '0' }, []]
      end
    end

    [@status, @headers, @response]
  end
end

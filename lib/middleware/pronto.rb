class Pronto
  class PathMatcher
    PATTERN = %r{^((?:/a/)(?<slug>[\w-]+)(?:/?)(?:(\?.*)*))$}.freeze

    def self.match(path)
      match = PATTERN.match(path)
      return match[:slug] if match
    end
  end

  class TemplateMatcher
    PRONTO_TEMPLATES = ['Default: Petition And Scroll To Share Greenpeace', 'Fundraiser With Title Below Image'].freeze

    def self.has_pronto_inclusion_template(liquid_layout_id)
      layout ||= LiquidLayout.find(liquid_layout_id)
      PRONTO_TEMPLATES.include?(layout&.title.to_s)
    rescue StandardError => e
      puts "Error trying to get liquid_layout with id #{liquid_layout_id} from pronto middleware - error: #{e.message}."
      false
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

      if page&.petition_page? && TemplateMatcher.has_pronto_inclusion_template(page&.liquid_layout_id)
        location = "#{Settings.pronto.domain}/#{req.fullpath}"
        return [301, { 'Location' => location, 'Content-Type' => 'text/html', 'Content-Length' => '0' }, []]
      end
    end

    [@status, @headers, @response]
  end
end

require 'yaml'

module ChampaignConfig
  extend self

  DEFAULT_YAML = 'config/champaign.yml'

  @location = DEFAULT_YAML

  def oauth_domain_whitelist
    root['google_oauth_whitelist']['domains']
  end

  def yaml_location=(path)
    @location = path
  end

  def reset!
    @location = DEFAULT_YAML
  end

  private

  def data
    @data = YAML.load_file(@location)
  end

  def root
    data['champaign']
  end
end

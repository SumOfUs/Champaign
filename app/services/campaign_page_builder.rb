class CampaignPageBuilder
  attr_reader :params

  class << self
    def create_with_plugins(params)
      new(params).create_with_plugins
    end
  end

  def initialize(params)
    @params = params
  end

  def create_with_plugins
    if page.save
      create_plugins
      push_to_queue
    end
    page
  end

  private

  def page
    @page ||= CampaignPage.new(params)
  end

  def create_plugins
    page.liquid_layout.partial_refs.each do |partial, ref|
      plugin_name = LiquidPartial.find_by(title: partial).plugin_name
      Plugins.create_for_page(plugin_name, page, ref)
    end
  end

  def push_to_queue
    ChampaignQueue.push({
      type: 'create',
      params: page.attributes
    }.as_json )
  end

  def params
    @params.merge(liquid_layout: default_layout)
  end

  def default_layout
    @default_layout ||= LiquidLayout.master
  end
end


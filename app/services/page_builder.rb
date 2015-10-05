class PageBuilder
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
    @page ||= Page.new(params)
  end

  def create_plugins
    page.liquid_layout.partial_refs.map do |partial, ref|
      plugin_name = LiquidPartial.find_by(title: partial).plugin_refs
    end.flatten.uniq.each do |plugin_name, ref|
      Plugins.create_for_page(plugin_name, page, ref)
    end
  end

  def push_to_queue
    ChampaignQueue.push(data_for_queue)
  end

  def params
    {liquid_layout_id: default_layout.id}.merge(@params)
  end

  def default_layout
    @default_layout ||= LiquidLayout.default
  end

  def data_for_queue
    {
      type: 'create',
      params: {
        slug: page.slug,
        id: page.id,
        title: page.title,
        language_code: page.language.code
      }
    }
  end
end


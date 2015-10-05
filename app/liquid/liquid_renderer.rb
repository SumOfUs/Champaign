class LiquidRenderer

  def initialize(page, layout: nil, country: nil)
    @page = page
    @markup = layout.content unless layout.blank?
    @country = country
  end

  def render
    template.render( data ).html_safe
  end

  def template
    @template ||= Liquid::Template.parse(markup)
  end

  def markup
    @markup ||= @page.liquid_layout ? @page.liquid_layout.content : default_markup
  end

  def default_markup
    File.read("#{Rails.root}/app/liquid/views/layouts/default.liquid")
  end

  def data
    @data ||= Plugins.data_for_view(@page).
                merge( @page.liquid_data ).
                merge( images: images ).
                merge( LiquidHelper.globals(country: @country) ).
                merge( shares: Shares.get_all(@page) ).
                deep_stringify_keys
  end

  def images
    @page.images.map do |img|
      { urls: { large: img.content.url(:large), small: img.content.url(:thumb) } }
    end
  end
end

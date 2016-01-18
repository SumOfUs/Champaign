class LiquidRenderer
  include Rails.application.routes.url_helpers

  def initialize(page, layout: nil, location: nil, member: nil, url_params: {})
    @page = page
    @markup = layout.content unless layout.blank?
    @location = location
    @member = member
    @url_params = url_params
    set_locale
  end

  def render
    Rails.cache.fetch(cache_key) do
      template.render( data ).html_safe
    end
  end

  def template
    @template ||= Liquid::Template.parse(markup)
  end

  def markup
    @markup ||= @page.liquid_layout ? @page.liquid_layout.content : default_markup
  end

  def default_markup
    File.read("#{Rails.root}/app/liquid/views/layouts/generic.liquid")
  end

  def data
    return @data if @data
    plugin_data = Plugins.data_for_view(@page, {form_values: @member.try(:attributes), donation_band: @url_params[:donation_band]})
    @data ||= plugin_data.
                merge( @page.liquid_data ).
                merge( images: images ).
                merge( primary_image: image_urls(@page.image_to_display) ).
                merge( LiquidHelper.globals(page: @page) ).
                merge( shares: Shares.get_all(@page) ).
                merge( url_params: @url_params ).
                merge( follow_up_url: follow_up_page_path(@page.id)).
                merge( member: member_hash ).
                merge( location: location).
                merge( outstanding_fields: outstanding_fields(plugin_data) ).
                merge( donation_bands: donation_bands(plugin_data) ).
                deep_stringify_keys
  end

  def images
    @page.images.map{ |img| image_urls(img) }
  end

  private

  def member_hash
    return nil if @member.blank?
    values = @member.attributes.symbolize_keys
    values[:welcome_name] = [values[:first_name], values[:last_name]].join(' ')
    values[:welcome_name] = values[:email] if values[:welcome_name].blank?
    values
  end

  def outstanding_fields(plugin_data)
    isolate_from_plugin_data(plugin_data, :outstanding_fields)
  end

  def donation_bands(plugin_data)
    isolate_from_plugin_data(plugin_data, :donation_bands).first
  end

  def isolate_from_plugin_data(plugin_data, field)
    plugin_values = plugin_data.deep_symbolize_keys[:plugins].values().map(&:values).flatten
    plugin_values.map{|plugin| plugin[field]}.flatten.compact
  end

  def location
    return @location if @location.blank?
    country_code = if @member.try(:country) && @member.country.length == 2
      @member.country
    else
      @location.country_code
    end
    return @location.data if country_code.blank?
    currency = Donations::Utils.currency_from_country_code(country_code)
    @location.data.merge(currency: currency)
  end

  def set_locale
    begin
      I18n.locale = @page.language.code if @page.language.present?
    rescue I18n::InvalidLocale
      # by setting the +i18n.enforce_available_locales+ flag to true but
      # catching the resulting error, it allows us to only set the locale
      # if it's one explicitly registered under +i18n.available_locales+
    end
  end

  def image_urls(img)
    return { urls: { large: '', small: '' } } if img.blank? || img.content.blank?
    { urls: { large: img.content.url(:large), small: img.content.url(:thumb) } }
  end

  def cache_key
    "rendered_liquid:#{@page.cache_key}:#{@page.liquid_layout.cache_key}"
  end
end


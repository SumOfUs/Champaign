class LiquidRenderer
  include Rails.application.routes.url_helpers

  def initialize(page, layout:, location: nil, member: nil, url_params: {})
    @page = page
    @layout = layout
    @location = location
    @member = member
    @url_params = url_params
  end

  def render
    Rails.cache.fetch(cache.key_for_markup) do
      template.render( markup_data ).html_safe
    end
  end

  def template
    @template ||= Liquid::Template.parse(@layout.content)
  end

  def images
    @page.images.map{ |img| image_urls(img) }
  end

  # this is all of the data that is needed to render the
  # liquid page. the only parts that change on each request
  # are not used when rendering markup
  def markup_data
    cacheable_data.merge(plugin_data).deep_stringify_keys
  end

  # this is all the data that we expect to change from request to request
  def personalization_data
    {
      url_params: @url_params,
      member:     member_data,
      location:   location,
      outstanding_fields: outstanding_fields,
      donation_bands: donation_bands,
      thermometer: thermometer,
      action_count: @page.action_count,
      show_direct_debit: show_direct_debit?
    }.deep_stringify_keys
  end

  private

  # the plugin serialization has lots of data that does not change
  # from request to request, but it has some. it's used in both
  # markup_data, which is used to create the cached html, and in
  # personalization_data, which is not cached.
  def plugin_data
    @plugin_data ||= Plugins.data_for_view(@page, {form_values: member_data, donation_band: @url_params[:donation_band]})
  end

  # this is all data used to render the page that we expect
  # will not change from request to request
  def cacheable_data
    @cacheable_data ||= {}.
      merge( @page.liquid_data ).
      merge( LiquidHelper.globals(page: @page) ).
      merge( images: images).
      merge( primary_image: image_urls(@page.image_to_display)).
      merge( shares: Shares.get_all(@page)).
      merge( follow_up_url: follow_up_url)
  end

  def member_data
    @member.try(:liquid_data)
  end

  def show_direct_debit?
    recurring_default = @url_params[:recurring_default] || isolate_from_plugin_data(:recurring_default).first
    DirectDebitDecider.decide([@location.try(:country_code), @member.try(:country)], recurring_default)
  end

  def outstanding_fields
    isolate_from_plugin_data(:outstanding_fields)
  end

  def donation_bands
    isolate_from_plugin_data(:donation_bands).first
  end

  def thermometer
    plugin_data.deep_symbolize_keys[:plugins][:thermometer].try(:values).try(:first)
  end

  def isolate_from_plugin_data(field)
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
    @location.data.merge(currency: currency, country: country_code)
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

  def cache
    @cache ||= Cache.new(@page, @layout)
  end

  def follow_up_url
    PageFollower.new_from_page(@page).follow_up_path
  end
end


class LiquidRenderer
  class Cache
    INVALIDATOR_KEY = 'cache_invalidator'

    def self.invalidate
      Rails.cache.increment(INVALIDATOR_KEY)
    end

    def initialize(page, layout)
      @page   = page
      @layout = layout
    end

    def key_for_markup
      "liquid_markup:#{invalidator_seed}:#{base}"
    end

    private

    def invalidator_seed
      Rails.cache.fetch(INVALIDATOR_KEY){ 0 }
    end

    def base
      "#{@page.cache_key}:#{@layout.try(:cache_key)}"
    end
  end
end


# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength

class LiquidRenderer
  include Rails.application.routes.url_helpers

  HIDDEN_FIELDS = %w[source bucket referrer_id rid akid referring_akid].freeze

  def initialize(page, location: nil, member: nil, url_params: {}, payment_methods: [])
    @page = page
    @location = location
    @member = member
    @url_params = url_params
    @payment_methods = payment_methods
  end

  def render
    render_layout(@page.liquid_layout)
  end

  def render_custom_without_cache(layout_name, data = {})
    layout = LiquidLayout.find_by_title!(layout_name)

    Liquid::Template
      .parse(layout.content)
      .render(markup_data.merge(data.stringify_keys)).html_safe
  end

  def render_follow_up
    render_layout(
      @page.follow_up_liquid_layout || @page.liquid_layout
    )
  end

  # this is all the data that we expect to change from request to request
  def personalization_data
    {
      url_params: @url_params,
      member:     member_data,
      location:   location,
      form_values: form_values,
      outstanding_fields: outstanding_fields,
      donation_bands: donation_bands,
      actions_thermometer: actions_thermometer,
      donations_thermometer: donations_thermometer,
      call_tool: call_tool_data,
      email_tool: email_tool_data,
      email_pension: email_pension_data,
      action_count: @page.action_count,
      payment_methods: @payment_methods
    }.deep_stringify_keys
  end

  private

  def render_layout(layout, extra_data = {})
    cache = Cache.new(@page.cache_key, layout.try(:cache_key))
    cache.fetch do
      Liquid::Template.parse(layout.content).render(markup_data.merge(extra_data.stringify_keys)).html_safe
    end
  end

  # this is all of the data that is needed to render the
  # liquid page. the only parts that change on each request
  # are not used when rendering markup
  def markup_data
    {
      images:        images,
      named_images:  named_images,
      primary_image: image_urls(@page.image_to_display),
      shares:        Shares.get_all(@page),
      locale:        @page.language&.code || 'en',
      follow_up_url: follow_up_url
    }
      .merge(@page.liquid_data)
      .merge(LiquidHelper.globals(page: @page))
      .merge(plugin_data)
      .deep_stringify_keys
  end

  def images
    @page.images.map { |img| image_urls(img) }
  end

  def named_images
    named = {}
    @page.images.each do |img|
      key = img.content_file_name.split('.').first
      named[key] = image_urls(img)
    end
    named
  end

  # the plugin serialization has lots of data that does not change
  # from request to request, but it has some. it's used in both
  # markup_data, which is used to create the cached html, and in
  # personalization_data, which is not cached.
  def plugin_data
    @plugin_data ||= Plugins.data_for_view(@page, form_values: form_values, donation_band: @url_params[:donation_band])
  end

  def member_data
    @member.try(:liquid_data)
  end

  def form_values
    field_keys = @page.plugins.map { |p| p.try(:form_fields) }.compact.flatten.map { |ff| ff[:name] }
    field_keys += HIDDEN_FIELDS
    (member_data || {}).merge(@url_params).stringify_keys.select { |k, _| field_keys.include? k }
  end

  def outstanding_fields
    isolate_from_plugin_data(:outstanding_fields)
  end

  def donation_bands
    isolate_from_plugin_data(:donation_bands).first
  end

  def actions_thermometer
    plugin_data.deep_symbolize_keys[:plugins][:actions_thermometer].try(:values).try(:first)
  end

  def donations_thermometer
    plugin_data.deep_symbolize_keys[:plugins][:donations_thermometer].try(:values).try(:first)
  end

  def call_tool_data
    CallTool::ExposedData.new(
      plugin_data.deep_symbolize_keys[:plugins][:call_tool],
      @url_params
    ).to_h
  end

  def email_tool_data
    plugin_data.deep_symbolize_keys[:plugins][:email_tool]
  end

  def email_pension_data
    plugin_data.deep_symbolize_keys[:plugins][:email_pension]
  end

  def isolate_from_plugin_data(field)
    plugin_values = plugin_data.deep_symbolize_keys[:plugins].values.map(&:values).flatten
    plugin_values.map { |plugin| plugin[field] }.flatten.compact
  end

  def location
    return @location if @location.blank?
    country_code = if @member.try(:country) && @member.country.length == 2
                     @member.country
                   else
                     @location.country_code
                   end
    return @location.data if country_code.blank?
    return { country: 'US' } if country_code == 'RD'
    currency = Donations::Utils.currency_from_country_code(country_code)
    @location.data.merge(currency: currency, country: country_code)
  end

  def image_urls(img)
    return { urls: { large: '', small: '', original: '' } } if img.blank? || img.content.blank?
    { urls: { large: img.content.url(:large), small: img.content.url(:thumb), original: img.content.url(:original) } }
  end

  def follow_up_url
    PageFollower.new_from_page(@page).follow_up_path
  end
end

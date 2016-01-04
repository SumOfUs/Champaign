class LiquidRenderer
  include Rails.application.routes.url_helpers

  def initialize(page, request_country: nil, member: nil, url_params: {})
    @page = page
    @request_country = request_country
    @member = member
    @url_params = url_params
    set_locale
  end

  def render
    template.render( data ).html_safe
  end

  def template
    @template ||= Liquid::Template.parse(markup)
  end

  def markup
    @markup ||= Rails.cache.fetch("#{@page.cache_key}_layout") do
      @page.liquid_layout ? @page.liquid_layout.content : default_markup
    end
  end

  def default_markup
    File.read("#{Rails.root}/app/liquid/views/layouts/generic.liquid")
  end

  def data
    @data ||= Rails.cache.fetch("#{@page.cache_key}_plugins") do
      Plugins.data_for_view(@page, {form_values: @member.try(:attributes), donation_band: @url_params[:donation_band]}).
                merge( @page.liquid_data ).
                merge( images: images ).
                merge( primary_image: image_urls(@page.image_to_display) ).
                merge( LiquidHelper.globals(request_country: @request_country, member: @member, page: @page) ).
                merge( shares: Shares.get_all(@page) ).
                merge( url_params: @url_params ).
                merge( follow_up_url: follow_up_page_path(@page.id)).
                deep_stringify_keys
    end
  end

  def images
    @page.images.map{ |img| image_urls(img) }
  end

  private

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

end

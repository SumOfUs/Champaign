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
    template.render( data ).html_safe
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
    @data ||= Plugins.data_for_view(@page, {form_values: @member.try(:attributes), donation_band: @url_params[:donation_band]}).
                merge( @page.liquid_data ).
                merge( images: images ).
                merge( primary_image: image_urls(@page.image_to_display) ).
                merge( LiquidHelper.globals(page: @page) ).
                merge( shares: Shares.get_all(@page) ).
                merge( url_params: @url_params ).
                merge( follow_up_url: follow_up_page_path(@page.id)).
                merge( member: member_hash ).
                merge( location: location).
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

  def location
    return @location if @location.blank? || @location.country_code.blank?
    currency = Donations::Utils.currency_from_country_code(@location.country_code)
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

end

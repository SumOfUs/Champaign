class LiquidRenderer
  include Rails.application.routes.url_helpers

  def initialize(page, layout: nil, request_country: nil, member: nil, url_params: {})
    @page = page
    @markup = layout.content unless layout.blank?
    @request_country = request_country
    @member = member
    @url_params = url_params
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
    @data ||= Plugins.data_for_view(@page, {form_values: @member.try(:attributes), url_params: @url_params}).
                merge( @page.liquid_data ).
                merge( images: images ).
                merge( primary_image: image_urls(@page.image_to_display) ).
                merge( LiquidHelper.globals(request_country: @request_country, member: @member, page: @page) ).
                merge( shares: Shares.get_all(@page) ).
                merge( url_params: @url_params ).
                merge( follow_up_url: follow_up_page_path(@page.id)).
                deep_stringify_keys
  end

  def images
    @page.images.map{ |img| image_urls(img) }
  end

  private

  def image_urls(img)
    return { urls: { large: '', small: '' } } if img.blank? || img.content.blank?
    { urls: { large: img.content.url(:large), small: img.content.url(:thumb) } }
  end

end

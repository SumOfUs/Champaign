module PagesHelper

  def page_nav_item(text, path, strict=true)
    selected = current_page?(path) || (!strict && request.path.include?(path))
    klass = selected ? 'active' : nil

    content_tag :li, class: klass do
      link_to text, path
    end
  end

  def serialize(data, field)
    hash = HashWithIndifferentAccess.new(data)
    (hash[field].nil? ? {} : hash[field]).to_json.html_safe
  end

  def prefill_link(new_variant)
    new_variant.description = "{LINK}" if new_variant.name == 'twitter'
    new_variant.body = "{LINK}" if new_variant.name == 'email'
    new_variant
  end

  def label_with_tooltip(f, field_sym, label_text, tooltip_text)
    tooltip = render partial: 'pages/tooltip', locals: {label_text: label_text, tooltip_text: tooltip_text}
    f.label field_sym do
      "#{label_text} #{tooltip}".html_safe
    end
  end

  def button_group_item(text, path)
    selected = current_page?(path)
    klass = selected ? 'btn-primary' : 'btn-default'
    klass << ' btn'

    link_to text, path, class: klass
  end

  def toggle_switch(state, active, label)
    klass = (active == state ? 'btn-primary' : '')
    klass += " btn toggle-button btn-default"

    content_tag :a, label, class: klass, data: { state: state }
  end

  def plugin_title(plugin)
    detail = plugin.ref.present? ? " - #{plugin.ref}" : ''
    "#{plugin.name}#{detail}"
  end

  # given a plugin object, this method returns the name
  # of a font-awesome icon for that plugin, either specific
  # to that plugin or falling back to a generic one.
  def plugin_icon(plugin)
    registered = {
      petition: 'hand-rock-o',
      thermometer: 'neuter',
      fundraiser: 'money'
    }
    name = plugin.name.underscore.to_sym
    registered.fetch( name, 'cubes' )
  end

  def determine_ascending
    if params[:search].nil?
      'asc'
    elsif params[:search][:order_by].nil?
      'asc'
    elsif params[:search][:order_by][1] == 'desc'
      'asc'
    else
      'desc'
    end
  end

  def determine_icon_location
    if params[:search].nil? or params[:search][:order_by].nil?
      return ''
    end
    if params[:search][:order_by].is_a? Array
      params[:search][:order_by][0]
    else
      params[:search][:order_by]
    end
  end

  def determine_icon_header
    if determine_ascending == 'asc'
      'glyphicon-menu-up'
    else
      'glyphicon-menu-down'
    end
  end

  def twitter_meta(page, share_card={})
    {
      card: 'summary_large_image',
      domain: Settings.homepage_url,
      site: t('share.twitter_handle'),
      creator: t('share.twitter_handle'),
      title: page.title,
      description: truncate(strip_tags(CGI.unescapeHTML(page.content)), length: 140),
      image: page.primary_image.try(:content).try(:url)
    }.merge(share_card) do |key, v1, v2|
      v2.blank? ? v1 : v2
    end
  end

  def facebook_meta(page, share_card={})
    {
      site_name: 'SumOfUs',
      title: page.title,
      description: truncate(strip_tags(CGI.unescapeHTML(page.content)), length: 260),
      url: page_url(page),
      type: 'website',
      article: { publisher: Settings.facebook_url },
      image: {
        width: '1200',
        height: '630',
        url: page.primary_image.try(:content).try(:url)
      }
    }.merge(share_card) do |key, v1, v2|
      if key == :image
        v2.blank? ? v1 : v1.merge(url: v2)
      else
        v2.blank? ? v1 : v2
      end
    end
  end

  def share_card(page)
    share = Share::Facebook.where(page_id: page.id).last
    return {} if share.blank?
    {
      title: share.title,
      description: share.description,
      image: Image.find_by(id: share.image_id).try(:content).try(:url)
    }
  end
end

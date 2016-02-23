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
end

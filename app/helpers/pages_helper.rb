module PagesHelper
  def page_nav_item(text, path, strict=true)
    selected = current_page?(path) || (!strict && request.path.include?(path))
    klass = selected ? 'active' : nil

    content_tag :li, class: klass do
      link_to text, path
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

    content_tag :a, label, class: klass
  end

  def plugin_title(plugin)
    detail = plugin.ref.present? ? " - #{plugin.ref}" : ''
    "#{plugin.name}#{detail}"
  end
end

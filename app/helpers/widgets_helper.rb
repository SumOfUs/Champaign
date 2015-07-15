module WidgetsHelper

  def try_content(widget, field)
    if widget.present? and widget.content.present? and widget.content.has_key? field.to_s
      return widget.content[field.to_s]
    else
      return ''
    end
  end
end

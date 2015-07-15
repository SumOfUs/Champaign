module WidgetsHelper

  def try_content(widget, field, is_boolean=false)
    if widget.present? and widget.content.present? and widget.content.has_key? field.to_s
      if is_boolean
        if widget.content[field.to_s] == "0" then return false else return true end
      end
      return widget.content[field.to_s]
    else
      return ''
    end
  end
end

class PageParameters < WidgetParameters

  private

  def permit(fields, root_symbol)
    format_widget_attributes(params, root_symbol)
    nested = save_nested(params, root_symbol)
    permitted = strip_nested(params, root_symbol).require(root_symbol).permit(
      fields,
      widgets_attributes: widget_shallow_fields
    )
    return restore_nested(permitted, nested)
  end

  # In order to pass strong params inspection with nested hashes with
  # unknown keys, we strip that part out and replace it after inspection
  def format_widget_attributes(params, root_symbol)
    if params[root_symbol][:widgets_attributes].present?
      if params[root_symbol][:widgets_attributes].respond_to? :values
        params[root_symbol][:widgets_attributes] = params[root_symbol][:widgets_attributes].values
      end
    end
  end

  def strip_nested(params, root_symbol)
    return params unless params[root_symbol][:widgets_attributes].present?
    params[root_symbol][:widgets_attributes].each do |a|
      widget_nesting_fields.each {|f| a.delete(f) }
    end
    return params
  end

  def save_nested(params, root_symbol)
    return nil unless params[root_symbol][:widgets_attributes].present?
    return params[root_symbol][:widgets_attributes].map do |a|
      backup = {}
      widget_nesting_fields.each do |key|
        if a.has_key? key then backup[key] = a[key] end
      end
      backup
    end
  end

  def restore_nested(permitted, saved)
    return permitted unless saved.present?
    permitted[:widgets_attributes].each_with_index do |a, ii|
      saved[ii].each_pair{ |key, backup| a[key] = backup }
    end
    return permitted
  end

end

class PageParameters < ActionParameter::Base

  private

  # In order to pass strong params inspection with nested hashes with
  # unknown keys, we strip that part out and replace it after inspection

  def format_widget_attributes params, root_symbol
    params[root_symbol][:widgets_attributes] = params[root_symbol][:widgets_attributes].values
  end

  def strip_json params, root_symbol
    return params unless params[root_symbol][:widgets_attributes].present?
    params[root_symbol][:widgets_attributes].each{ |a| a.delete(:content) }
    return params
  end

  def save_json params, root_symbol
    return nil unless params[root_symbol][:widgets_attributes].present?
    ret = params[root_symbol][:widgets_attributes].map do |a|
      if a.has_key? :content then a[:content] else nil end
    end
    return ret
  end

  def restore_json permitted, saved
    return permitted unless saved.present?
    permitted[:widgets_attributes].each_with_index do |a, ii|
      a[:content] = saved[ii] unless saved[ii].nil?
    end
    return permitted
  end

end

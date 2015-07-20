class PageParameters < ActionParameter::Base

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

  def widget_shallow_fields
    [
      :goal, :count, :autoincrement,              # thermometer widget
      :html,                                      # raw html widget
      :text_body_html,                            # text body widget
      :petition_text, :form_button_text, :require_full_name,                 # petition widget
      :require_email_address, :require_country, :require_state,              # petition widget
      :require_postal_code, :require_address, :require_city, :require_phone, # petition widget

      :id, :type, :_destroy, :page_display_order # base widget fields
    ]
  end

  def widget_nesting_fields
    [
      :checkboxes,
      :select_box,
      :comment_textarea,
      :call_in_form,
      :letter_sent_form,
      :image_attributes
    ]
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

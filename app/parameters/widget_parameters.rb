class WidgetParameters < ActionParameter::Base

  def permit
    nested = save_nested(params)
    permitted = strip_nested(params).require(:widget).permit(widget_shallow_fields)
    return restore_nested(permitted, nested)
  end

  private

  def strip_nested(params)
    widget_nesting_fields.each {|f| params[:widget].delete(f) }
    return params
  end

  def save_nested(params)
    backup = {}
    widget_nesting_fields.each do |key|
      if params[:widget].has_key? key then backup[key] = params[:widget][key] end
    end
    return backup
  end

  def restore_nested(permitted, saved)
    saved.each_pair{ |key, backup| permitted[key] = backup } if saved.present?
    return permitted
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

end

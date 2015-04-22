class WidgetTypeParameter < ActionParameter::Base

  def permit
    params.require(:widget_type).permit(:widget_name, :specifications, :partial_path, :form_partial_path, :active)
  end
end
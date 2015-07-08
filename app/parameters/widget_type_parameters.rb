# The parameters classes specify which parameters are allowed for mass assignment and permits those
class WidgetTypeParameters < ActionParameter::Base

  def permit
    params.require(:widget_type).permit(:id, :widget_name, :specifications, :active)
  end
end

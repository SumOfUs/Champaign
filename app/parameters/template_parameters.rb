# The parameters classes specify which parameters are allowed for mass assignment and permits those
class TemplateParameters < ActionParameter::Base

  def permit
    params.require(:template).permit(:template_name, :active)
  end
end

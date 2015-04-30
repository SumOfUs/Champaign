class TemplateParameters < ActionParameter::Base

  def permit
    params.require(:template).permit(:template_name, :active)
  end
end
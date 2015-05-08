# The parameters classes specify which parameters are allowed for mass assignment and permits those
class LanguageParameters < ActionParameter::Base

  def permit
    params.require(:language).permit(:language_code, :language_name)
  end
end
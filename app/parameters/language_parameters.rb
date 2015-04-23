class LanguageParameters < ActionParameter::Base

  def permit
    params.require(:language).permit(:language_code, :language_name)
  end
end
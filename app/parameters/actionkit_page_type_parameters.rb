class ActionkitPageTypeParameters < ActionParameter::Base

  def permit
    params.require(:actionkit_page_type).permit(:actionkit_page_type)
  end
end
class ActionKitPageTypeParameters < ActionParameter::Base

  def permit
    p params.object_id
    params.require(:actionkit_page_type).permit(:actionkit_page_type)
  end
end
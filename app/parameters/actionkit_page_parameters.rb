class ActionkitPageParameters < ActionParameter::Base

  def permit
    params.require(:actionkit_page).permit(:campaign_page_id, :actionkit_page_type_id)
  end
end
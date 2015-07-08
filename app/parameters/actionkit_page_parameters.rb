# The parameters classes specify which parameters are allowed for mass assignment and permits those
class ActionkitPageParameters < ActionParameter::Base

  def permit
    params.require(:actionkit_page).permit(:id, :campaign_page_id, :actionkit_page_type_id)
  end
end

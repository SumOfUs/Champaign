# The parameters classes specify which parameters are allowed for mass assignment and permits those
class MemberParameters < ActionParameter::Base

  def permit
    params.require(:member).permit(:id, :email, :country, :postal, :first_name, :last_name, :actionkit_member_id)
  end
end

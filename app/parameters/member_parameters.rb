class MemberParameters < ActionParameter::Base

  def permit
    params.require(:member).permit(:email_address, :actionkit_member_id)
  end
end
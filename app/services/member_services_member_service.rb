# frozen_string_literal: true

# It's a member service... for member services!
class MemberServicesMemberService
  attr_reader :member, :errors, :status

  def initialize(params)
    @params = params
  end

  def update
    @member = Member.find_by_email(@params[:email])

    unless @member
      @errors = ["No member associated with email address #{@params[:email]}."]
      @status = 404
      return false
    end

    if @member.update_attributes(@params)
      return true
    else
      @errors = ["Updating member details failed for #{@member.email}."]
      @status = 422
      return false
    end
  end
end

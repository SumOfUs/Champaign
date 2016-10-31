# frozen_string_literal: true
class CreateMemberForApiMembersController
  attr_reader :member, :errors

  def initialize(params)
    @params = params
  end

  def create
    validator = FormValidator.new(@params, member_validation)

    if validator.valid?
      @member = Member.find_or_initialize_by(email: @params[:email])
      @member.assign_attributes(@params)
      if @member.save
        @member.publish_subscription
        return true
      else
        @errors = member.errors
        return false
      end
    else
      @errors = validator.errors
      return false
    end
  end

  private

  def member_validation
    [
      { name: 'email', data_type: 'email', required: true },
      { name: 'country', data_type: 'country', required: false },
      { name: 'postal', data_type: 'postal', required: false },
      { name: 'name', data_type: 'text', required: true }
    ]
  end
end

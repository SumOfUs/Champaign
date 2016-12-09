# frozen_string_literal: true
class CreateMemberForApiMembersController
  attr_reader :member, :errors

  def initialize(params)
    @params = params.symbolize_keys
  end

  def create
    validator = FormValidator.new(member_params, member_validation)

    if validator.valid?
      @member = Member.find_or_initialize_by(email: member_params[:email])
      @member.assign_attributes(member_params)
      if @member.save
        @member.publish_signup(@params[:locale])
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

  def member_params
    return @member_params if @member_params.present?
    allowed = Member.new.attributes.keys.map(&:to_sym) + [:name]
    @member_params = @params.select { |k, _| allowed.include? k }
  end

  def member_validation
    [
      { name: 'email', data_type: 'email', required: true },
      { name: 'country', data_type: 'country', required: true },
      { name: 'postal', data_type: 'postal', required: false },
      { name: 'name', data_type: 'text', required: true }
    ]
  end
end

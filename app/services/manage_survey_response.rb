# frozen_string_literal: true
class ManageSurveyResponse
  attr_accessor :action

  def initialize(page:, form:, params:, action_id: nil)
    @form = form
    @params = sanitize_params(params, form)
    @validator = FormValidator.new(@params, @form.form_elements)
    @action = action_id.present? ? Action.find(action_id) : Action.new(page: page)
  end

  def run
    assign_member
    if action_valid?
      update_member
      update_action
      publish_event
    end

    action_valid?
  end

  def errors
    @validator.errors
  end

  private

  def sanitize_params(params, form)
    params.slice(*form.element_names, 'akid')
  end

  def assign_member
    return unless @params[:email].present?
    @action.member = Member.find_or_initialize_by(email: @params[:email].downcase)
  end

  def action_valid?
    @action.member.present? && @validator.valid?
  end

  def update_member
    MemberUpdater.run(@action.member, @params)
  end

  def update_action
    @action.form_data.merge!(@params)
    @action.save!
  end

  def publish_event
    ActionQueue::Pusher.push(:new_survey_response, @action)
  end
end

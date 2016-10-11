class ManageSurveyResponse
  attr_accessor :action

  def initialize(page:, form:, params:, action_id:nil)
    @form = form
    @params = sanitize_params(params, form)
    @validator = FormValidator.new(@params, @form.form_elements)
    @action = action_id.present? ?  Action.find(action_id) : Action.new(page: page)
  end

  def run
    if @validator.valid?
      assign_member
      update_member
      update_action
      publish_event
    end

    @validator.valid?
  end

  def errors
    @validator.errors
  end

  private

  def sanitize_params(params, form)
    params.slice(*form.form_elements.map(&:name).map(&:to_sym))
  end

  def assign_member
    @action.member ||= if @params[:akid].present?
      Member.find_by_akid(@params[:akid])
    elsif @params[:email].present?
      Member.find_or_initialize_by(email: @params[:email])
    end
  end

  def update_member
    if @action.member.present?
      MemberUpdater.run(@action.member, @params)
    end
  end

  def update_action
    @action.form_data[@form.id] = @params
    @action.save!
  end

  def publish_event
    ActionQueue::Pusher.push(:new_survey_response, @action)
  end
end

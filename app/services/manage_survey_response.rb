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
      update_action
    end

    @validator.valid?
  end

  def errors
    @validator.errors
  end

  private

  def assign_member
    if @params[:email].present?
      @action.member = Member.find_or_create_by!(email: @params[:email])
    end
  end

  def update_action
    @action.form_data[@form.id] = @params
    @action.save!
  end

  def sanitize_params(params, form)
    params.slice(*form.form_elements.map(&:name).map(&:to_sym))
  end
end

class ManageAction
  def initialize(params)
    @params = params
  end

  def create
    Action.find_or_create_by( action_user: action_user, page: page ) do |action|
      queue_message = {type: 'action', params: {slug: page.slug, email: action_user.email}.merge(@params)}
      ChampaignQueue.push(queue_message)
      action.form_data = @params
    end
  end

  private

  def previous_action
    Action.where(action_user: action_user, page_id: page).first
  end

  def action_user
    @user ||= ActionUser.find_or_create_by(email: @params[:email])
  end

  def page
    @page ||= Page.find(@params[:page_id])
  end
end


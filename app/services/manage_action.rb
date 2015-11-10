class ManageAction
  def self.create(params)
    new(params).create
  end

  def initialize(params)
    @params = params
  end

  def create
    return previous_action if previous_action.present?

    ChampaignQueue.push(queue_message)
    Action.create( action_user: action_user, page: page, form_data: @params )
  end

  private

  def queue_message
    {
      type: 'action',
      params: {
        slug: page.slug,
        body: @params
      }
    }
  end

  def previous_action
    @previous_action ||= Action.where(action_user: action_user, page_id: page).first
  end

  def action_user
    return @user if @user.present?
    @user = ActionUser.find_or_create_by(email: @params[:email])
    permitted = @user.attributes.keys.map(&:to_sym).reject!{|k| k == :id}
    @user.assign_attributes(@params.compact.keep_if{ |k| permitted.include? k })
    @user.save if @user.changed
    @user
  end

  def page
    @page ||= Page.find(@params[:page_id])
  end
end


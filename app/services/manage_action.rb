class ManageAction
  def self.create(params)
    new(params).create
  end

  def initialize(params)
    @params = params
  end

  def create
    return false if Action.exists?( action_user: action_user, page: page )

    action = Action.create( action_user: action_user, page: page, form_data: @params )
    ChampaignQueue.push(queue_message)

    action
  end

  private

  def queue_message
    {
      type: 'action',
      params: {
        slug: page.slug,
        email: action_user.email
      }.merge(@params)
    }
  end

  def previous_action
    Action.where(action_user: action_user, page_id: page).first
  end

  def action_user
    return @user if @user.present?
    @user = ActionUser.find_or_create_by(email: @params[:email])
    @params.each_pair do |key, value|
      # here we choose not to overwrite newly blank values.
      @user[key] = value if @user.respond_to?("#{key}=".to_sym) && value.present?
    end
    @user.save if @user.changed
    @user
  end

  def page
    @page ||= Page.find(@params[:page_id])
  end
end


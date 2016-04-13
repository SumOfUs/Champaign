require_relative 'action_queue'

module ActionBuilder
  def build_action(extra_attrs = {})
    subscribed_member = !existing_member?
    action = Action.create({
      member: member,
      page: page,
      form_data: @params,

      # indicates if action subscribed the member
      subscribed_member: subscribed_member
    }.merge(extra_attrs))

    ActionQueue::Pusher.push(action)
    Analytics::Page.increment(page.id, new_member: subscribed_member)

    action
  end

  def previous_action
    return nil unless existing_member?
    @previous_action ||= Action.where(member: member, page_id: page).first
  end

  def existing_member
    @existing_member ||= Member.find_or_initialize_by( email: @params[:email] )
  end

  def existing_member?
    !!existing_member
  end

  def member
    return @user if @user.present?
    @user = existing_member

    if @params.has_key? :name
      @user.name = @params[:name]
    end

    @user.assign_attributes(
      filtered_params.tap do |data|
        id = AkidParser.parse(@params[:akid], Settings.action_kit.akid_secret)[:actionkit_user_id]
        data[:actionkit_user_id] = id unless id.blank?
      end
    )

    @user.save if @user.changed
    @user
  end

  def filtered_params
    hash = @params.try(:to_unsafe_hash) || @params.to_h # for ActionController::Params
    hash.symbolize_keys.compact.keep_if{ |k| permitted_keys.include? k }
  end

  def permitted_keys
    Member.new.attributes.keys.map(&:to_sym).reject!{|k| k == :id}
  end

  def page
    @page ||= Page.find(@params[:page_id])
  end
end


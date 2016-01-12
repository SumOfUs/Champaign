module ActionBuilder

  def build_action
    Action.create( member: member, page: page, form_data: @params )
  end

  def previous_action
    @previous_action ||= Action.where(member: member, page_id: page).first
  end

  def member
    return @user if @user.present?
    @user = Member.find_or_create_by(email: @params[:email])
    if @params.has_key? :name
      @user.name = @params[:name]
    end
    @user.assign_attributes(filtered_params)
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

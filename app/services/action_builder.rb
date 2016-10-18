# frozen_string_literal: true
module ActionBuilder
  def build_action(extra_attrs = {})
    @extra_attrs = extra_attrs
    subscribed_member = !existing_member?
    action = Action.create({
      member: member,
      page: page,
      form_data: form_data,

      # indicates if action subscribed the member
      subscribed_member: subscribed_member
    }.merge(extra_attrs))

    ActionQueue::Pusher.push(action) unless @skip_queue
    Analytics::Page.increment(page.id, new_member: subscribed_member) unless @skip_counter

    action
  end

  def previous_action
    return nil unless existing_member?
    @previous_action ||= Action.not_donation.where(member: member, page_id: page).first

    # looks up other actions the user might have taken on this campaign
    if page.campaign.present? && @previous_action.blank?
      page.campaign.pages.each do |connected_page|
        next if connected_page.id == page.id
        @previous_action ||= Action.not_donation.where(member: member, page_id: connected_page.id).first
      end
    end
    @previous_action
  end

  def existing_member
    @existing_member ||= Member.find_by(email: @params[:email])
  end

  def existing_member?
    existing_member ? true : false
  end

  def member
    return @user if @user.present?
    @user = existing_member || Member.new(email: @params[:email])

    update_member_fields
    update_donor_status

    @user.save if @user.changed
    @user
  end

  def filtered_params
    hash = @params.try(:to_unsafe_hash) || @params.to_h # for ActionController::Params
    hash.symbolize_keys.compact.keep_if { |k| permitted_keys.include? k }
  end

  def permitted_keys
    Member.new.attributes.keys.map(&:to_sym).reject! { |k| k == :id }
  end

  def page
    @page ||= Page.find(@params[:page_id])
  end

  private

  def update_member_fields
    ak_user_id = AkidParser.parse(@params[:akid], Settings.action_kit.akid_secret)[:actionkit_user_id]
    @user.actionkit_user_id = ak_user_id unless ak_user_id.blank?

    @user.name = @params[:name] if @params.key? :name
    @user.assign_attributes(filtered_params)
  end

  def update_donor_status
    return unless is_donation?
    return if @user.recurring_donor?
    new_status = is_recurring_donation? ? 'recurring_donor' : 'donor'
    @user.donor_status = new_status
  end

  def is_donation?
    @extra_attrs && @extra_attrs[:donation]
  end

  def is_recurring_donation?
    @params && @params[:is_subscription]
  end

  def form_data
    @params.tap do |params|
      if params[:referrer_id]
        member = Member.find_by(id: params[:referrer_id])
        params[:action_referrer_email] = member.email if member.try(:email).present?
      end
    end
  end
end

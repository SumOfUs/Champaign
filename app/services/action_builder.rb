# frozen_string_literal: true
module ActionBuilder
  def build_action(extra_attrs = {})
    @extra_attrs = extra_attrs
    subscribed_member = !existing_member?
    action = Action.create({
      member: member,
      page: page,
      form_data: @params,

      # indicates if action subscribed the member
      subscribed_member: subscribed_member
    }.merge(extra_attrs))

    ActionQueue::Pusher.push(:new_action, action)
    Analytics::Page.increment(page.id, new_member: subscribed_member)

    action
  end

  def previous_action
    return nil unless existing_member?
    @previous_action ||= Action.where(member: member, page_id: page).first

    # looks up other actions the user might have taken on this campaign
    if page.campaign.present? && @previous_action.blank?
      page.campaign.pages.each do |connected_page|
        next if connected_page.id == page.id
        @previous_action ||= Action.where(member: member, page_id: connected_page.id).first
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

    @params[:donor_status] = donor_status if donor_status.present?
    MemberUpdater.run(@user, @params)

    @user
  end

  def page
    @page ||= Page.find(@params[:page_id])
  end

  private

  def donor_status
    return unless is_donation?
    return if @user.recurring_donor?
    is_recurring_donation? ? 'recurring_donor' : 'donor'
  end

  def is_donation?
    return false if @extra_attrs.blank?
    @extra_attrs[:donation] ? true : false
  end

  def is_recurring_donation?
    @params[:is_subscription] ? true : false
  end
end

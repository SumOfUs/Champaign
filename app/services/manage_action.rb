# frozen_string_literal: true

class ManageAction
  attr_reader :params

  def self.create(params, extra_params: {}, skip_queue: false, skip_counter: false)
    new(params, extra_params: extra_params, skip_queue: skip_queue, skip_counter: skip_counter).create
  end

  def initialize(params, extra_params: {}, skip_queue: false, skip_counter: false)
    @params = params
    @skip_queue = skip_queue
    @skip_counter = skip_counter
    @extra_attrs = extra_params
  end

  def create
    if multiple_actions_allowed?
      build_action(@extra_attrs)
    else
      previous_action
    end
  end

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

    ActionQueue::Pusher.push(:new_action, action) unless @skip_queue
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
    @existing_member ||= Member.find_by_email(@params[:email])
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

  private

  def donor_status
    return unless donation?
    return if @user.recurring_donor?
    recurring_donation? ? 'recurring_donor' : 'donor'
  end

  def donation?
    @extra_attrs && @extra_attrs[:donation]
  end

  def recurring_donation?
    @params && @params[:is_subscription]
  end

  def form_data
    @params.tap do |params|
      email = MemberEmailGuesser.run(params)
      params[:action_referrer_email] = email if email.present?
    end
  end

  def multiple_actions_allowed?
    return true if donation? || previous_action.nil?
    page.allow_duplicate_actions?
  end

  def page
    @page ||= Page.find(params[:page_id])
  end
end

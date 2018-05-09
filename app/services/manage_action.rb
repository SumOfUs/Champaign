# frozen_string_literal: true

class ManageAction
  def self.create(params, extra_params: {}, skip_queue: false, skip_counter: false)
    new(params, extra_params: extra_params, skip_queue: skip_queue, skip_counter: skip_counter).create
  end

  def initialize(params, extra_params: {}, skip_queue: false, skip_counter: false)
    @params = params.clone
    @skip_queue = skip_queue
    @skip_counter = skip_counter
    @extra_attrs = extra_params.clone
    sanitize_params
  end

  def create
    if should_create_new_action?
      create_action
    else
      # TODO: Update existing member
      previous_action
    end
  end

  def create_action
    action_params = {
      page: page
    }.merge(@extra_attrs)

    if existing_member.present?
      action_params[:member] = existing_member
      action_params[:form_data] = form_data
      action_params[:subscribed_member] = false
      update_existing_member
      @action = Action.create!(action_params)
      publish_event
    elsif !requires_consent? || @params[:consented]
      action_params[:member] = create_member
      action_params[:form_data] = form_data
      action_params[:subscribed_member] = true
      @action = Action.create!(action_params)
      publish_event
    else
      action_params[:form_data] = @params.slice(:name, :first_name, :last_name)
      action_params[:subscribed_member] = false
      @action = Action.create!(action_params)
    end

    Analytics::Page.increment(page.id, new_member: action_params[:subscribed_member]) unless @skip_counter

    @action
  end

  def previous_action
    return nil unless existing_member.present?
    @previous_action ||= Action.not_donation.where(member: existing_member, page_id: page).first

    if page.campaign.present? && @previous_action.blank?
      page.campaign.pages.each do |connected_page|
        next if connected_page.id == page.id
        @previous_action ||= Action.not_donation.where(member: existing_member, page_id: connected_page.id).first
      end
    end
    @previous_action
  end

  private

  def create_member
    member = Member.new(email: @params[:email])
    MemberUpdater.run(member, @params)
    member
  end

  def update_existing_member
    MemberUpdater.run(existing_member, @params)
  end

  def existing_member
    @existing_member ||= Member.find_by_email(@params[:email])
  end

  def publish_event
    ActionQueue::Pusher.push(:new_action, @action) unless @skip_queue
  end

  def form_data
    @params.tap do |params|
      email = MemberEmailGuesser.run(params)
      params[:action_referrer_email] = email if email.present?
    end
  end

  def should_create_new_action?
    @extra_attrs[:donation] || previous_action.nil? || page.allow_duplicate_actions?
  end

  def page
    @page ||= Page.find(@params[:page_id])
  end

  def sanitize_params
    if @extra_attrs[:donation]
      @params[:donor_status] = @params[:is_subscription] ? 'recurring_donor' : 'donor'
    end
  end

  def requires_consent?
    Country[@params[:country]]&.in_eea? && !@extra_attrs[:donation]
  end
end

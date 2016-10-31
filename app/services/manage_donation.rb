# frozen_string_literal: true
class ManageDonation
  include ActionBuilder

  def self.create(params:)
    new(params: params).create
  end

  def initialize(params:)
    @params = params
  end

  def create
    build_action(donation: true)
  end
end

class DonationActionBuilder
  def initialize(params, &block)
    @params = params
    @block = block
  end

  def build
    action = Action.new(
      member:     member,
      page:       page,
      form_data:  @params,
      subscribed_member: subscribed_member
    )

    yield(action) if @block
  end

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

    ActionQueue::Pusher.push(action)
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
    @existing_member ||= Member.find_by_email(@params[:email])
  end

  def existing_member?
    !existing_member.nil?
  end

  def member
    return @user if @user.present?
    @user = existing_member || Member.new(email: @params[:email])

    update_member_fields
    update_donor_status

    @user.save! if @user.changed
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
    return unless donation?
    return if @user.recurring_donor?
    new_status = recurring_donation? ? 'recurring_donor' : 'donor'
    @user.donor_status = new_status
  end

  def donation?
    return false if @extra_attrs.blank?
    !@extra_attrs[:donation].nil?
  end

  def recurring_donation?
    !@params[:is_subscription].nil?
  end
end

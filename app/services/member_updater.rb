# frozen_string_literal: true

class MemberUpdater
  def self.run(member, params)
    new(member, params).run
  end

  def initialize(member, params)
    @member = member
    @params = params.try(:to_unsafe_hash) || params.to_h
    @params = @params.symbolize_keys.compact
  end

  def run
    @member.name = @params[:name] if @params.key? :name
    @member.actionkit_user_id = action_kit_user_id if action_kit_user_id.present?
    @member.donor_status = @params[:donor_status] if @params[:donor_status] && !@member.recurring_donor?
    @member.assign_attributes(
      @params.slice(
        :email, :country, :first_name, :last_name, :city, :postal, :title, :address1, :address2, :consented
      )
    )
    @member.more = (@member.more || {}).merge(@params.select { |k| belongs_in_more? k })
    @member.save!
  end

  private

  def action_kit_user_id
    AkidParser.parse(@params[:akid], Settings.action_kit.akid_secret)[:actionkit_user_id]
  end

  def member_attributes
    @member_attributes ||= Member.column_names.map(&:to_sym).reject { |k| k == :id }
  end

  def belongs_in_more?(k)
    !member_attributes.include?(k) && ActionKitFields.has_valid_form(k)
  end
end

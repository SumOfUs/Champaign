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
    @member.assign_attributes(@params.select { |k| member_attributes.include? k })
    @member.more = (@member.more || {}).merge(@params.select { |k| belongs_in_more? k })
    @member.save!
  end

  private

  def action_kit_user_id
    AkidParser.parse(@params[:akid], Settings.action_kit.akid_secret)[:actionkit_user_id]
  end

  def member_attributes
    @member_attributes ||= Member.new.attributes.keys.map(&:to_sym).select{ |k| k != :id }
  end

  def belongs_in_more?(k)
    !member_attributes.include?(k) && ActionKitFields.has_valid_form(k)
  end
end

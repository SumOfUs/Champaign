# frozen_string_literal: true
# == Schema Information
#
# Table name: calls
#
#  id                  :integer          not null, primary key
#  page_id             :integer
#  member_id           :integer
#  member_phone_number :string
#  created_at          :datetime
#  updated_at          :datetime
#  target_call_info    :jsonb            not null
#  member_call_events  :json             is an Array
#  twilio_error_code   :integer
#  target              :json
#  status              :integer          default(0)
#

class Call < ActiveRecord::Base
  enum status: [:unstarted, :started, :connected]
  belongs_to :page
  belongs_to :member

  validates :page, presence: true
  validates :member_phone_number, presence: true
  validates :target, presence: true

  validate :member_phone_number_is_valid

  delegate :sound_clip, to: :call_tool

  def target_phone_number
    target.phone_number
  end

  def target_id=(id)
    self.target = call_tool.find_target(id)
  end

  def target=(target_object)
    write_attribute(:target, target_object&.to_hash)
  end

  def target
    target_json = read_attribute(:target)
    CallTool::Target.new(target_json) if target_json.present?
  end

  private

  def call_tool
    @call_tool ||= Plugins::CallTool.find_by_page_id!(page.id)
  end

  def member_phone_number_is_valid
    return if member_phone_number.blank?
    valid_characters = (/\A[0-9\-\+\(\) \.]+\z/i =~ member_phone_number).present?
    has_at_least_six_numbers = (member_phone_number.scan(/[0-9]/).size > 5)
    unless valid_characters
      errors.add(:member_phone_number, I18n.t('validation.is_invalid_phone'))
    end

    unless has_at_least_six_numbers
      errors.add(:member_phone_number, I18n.t('call_tool.errors.phone_number.too_short'))
    end
  end
end

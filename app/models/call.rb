# frozen_string_literal: true

# == Schema Information
#
# Table name: calls
#
#  id                  :integer          not null, primary key
#  member_call_events  :json             is an Array
#  member_phone_number :string
#  status              :integer          default("unstarted")
#  target              :json
#  target_call_info    :jsonb            not null
#  twilio_error_code   :integer
#  created_at          :datetime
#  updated_at          :datetime
#  action_id           :integer
#  member_id           :integer
#  page_id             :integer
#
# Indexes
#
#  index_calls_on_target_call_info  (target_call_info) USING gin
#

class Call < ApplicationRecord
  TWILIO_STATUSES = %w[completed answered busy no-answer failed canceled unknown].freeze
  enum status: %i[unstarted started connected failed]
  belongs_to :page
  belongs_to :member
  belongs_to :action

  validates :page, presence: true
  validates :member_phone_number, presence: true
  validates :target, presence: true
  validate :member_phone_number_is_valid

  delegate :sound_clip, to: :call_tool
  delegate :menu_sound_clip, to: :call_tool

  scope :not_failed, -> { where.not(status: statuses['failed']) }

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

  # Returns: completed | answered | busy | no-answer |
  #          failed | canceled | unknown
  def target_call_status
    target_call_info['DialCallStatus'] || 'unknown'
  end

  def call_tool
    @call_tool ||= Plugins::CallTool.find_by_page_id!(page.id)
  end

  def caller_id
    if target&.caller_id.present?
      target.caller_id
    else
      call_tool.caller_phone_number&.number
    end
  end

  private

  def member_phone_number_is_valid
    return if member_phone_number.blank?

    valid_characters = (/\A[0-9\-\+\(\) \.]+\z/i =~ member_phone_number).present?
    has_at_least_six_numbers = (member_phone_number.scan(/[0-9]/).size > 5)
    errors.add(:member_phone_number, I18n.t('validation.is_invalid_phone')) unless valid_characters

    errors.add(:member_phone_number, I18n.t('call_tool.errors.phone_number.too_short')) unless has_at_least_six_numbers

    unless Phony.plausible?(member_phone_number)
      errors.add(:member_phone_number, I18n.t('call_tool.errors.phone_number.is_invalid'))
    end
  end
end

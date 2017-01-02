# == Schema Information
#
# Table name: calls
#
#  id                  :integer          not null, primary key
#  page_id             :integer
#  member_id           :integer
#  member_phone_number :string
#  target_id           :integer
#  created_at          :datetime
#  updated_at          :datetime
#

class Call < ActiveRecord::Base
  belongs_to :page
  belongs_to :member

  validates :page, presence: true
  validates :member_phone_number, presence: true
  validates :target_id, presence: true

  validate :target_id_is_valid
  validate :member_phone_number_is_valid

  def target_phone_number
    call_tool.find_target(target_id)['phone']
  end

  private

  def call_tool
    @call_tool ||= Plugins::CallTool.find_by_page_id(page.id) ||
      raise(ActiveRecord::NotFound)
  end

  def target_id_is_valid
    if call_tool.find_target(target_id).blank?
      errors.add(:target_id, "doesn't match an target in the page call tool plugin")
    end
  end

  def member_phone_number_is_valid
    return if member_phone_number.blank?
    valid_characters = (/\A[0-9\-\+\(\) ]+\z/i =~ member_phone_number).present?
    has_at_least_six_numbers = (member_phone_number.scan(/[0-9]/).size > 5)
    if !valid_characters || !has_at_least_six_numbers
      errors.add(:member_phone_number, I18n.t('validation.is_invalid_phone'))
    end
  end
end

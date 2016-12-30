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
    #TODO Impplement: check that the target id actually exists in the call tool
    true
  end

  def member_phone_number_is_valid
    #TODO validate format?
    true
  end
end

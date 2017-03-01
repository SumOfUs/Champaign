# frozen_string_literal: true
# == Schema Information
#
# Table name: calls
#
#  id                  :integer          not null, primary key
#  page_id             :integer
#  member_id           :integer
#  member_phone_number :string
#  target_index        :integer
#  created_at          :datetime
#  updated_at          :datetime
#  log                 :jsonb            not null
#  member_call_events  :json             is an Array
#  twilio_error_code   :integer
#

FactoryGirl.define do
  factory :call do
    association :page, :with_call_tool
    member_phone_number { Faker::PhoneNumber.cell_phone }
    target { build(:call_tool_target) }
  end
end

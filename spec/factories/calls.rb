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

FactoryGirl.define do
  factory :call do
    association :page, :with_call_tool
    member_phone_number { Faker::PhoneNumber.cell_phone }
    target { build(:call_tool_target) }

    trait :with_busy_status do
      target_call_info('DialCallStatus' => 'busy')
    end

    trait :with_completed_status do
      target_call_info('DialCallStatus' => 'completed')
    end
  end
end

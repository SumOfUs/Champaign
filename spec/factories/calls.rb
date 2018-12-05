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
#  target_call_info    :jsonb            default("{}"), not null
#  member_call_events  :json             default("{}"), is an Array
#  twilio_error_code   :integer
#  target              :json
#  status              :integer          default("0")
#  action_id           :integer
#

FactoryBot.define do
  factory :call do
    association :page, :with_call_tool
    member_phone_number {
      ['+448008085429', '+448000119712', '+61261885481', '+13437003482'].sample
    }
    target { build(:call_tool_target) }

    trait :with_busy_target_status do
      connected
      target_call_info { { 'DialCallStatus' => 'busy' } }
    end

    trait :with_completed_target_status do
      connected
      target_call_info { { 'DialCallStatus' => 'completed' } }
    end

    trait :unstarted do
      status { :unstarted }
    end

    trait :started do
      status { :started }
    end

    trait :connected do
      status { :connected }
    end

    trait :failed do
      status { :failed }
    end
  end
end

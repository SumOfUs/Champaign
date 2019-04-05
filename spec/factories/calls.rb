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

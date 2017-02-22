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
#

FactoryGirl.define do
  factory :call do
    association :page, :with_call_tool
    member_phone_number { Faker::PhoneNumber.cell_phone }
    target_index 0
  end
end

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

FactoryGirl.define do
  factory :call do
    association :page, :with_call_tool
    member_phone_number { Faker::PhoneNumber.phone_number }
    target_id 1
  end
end

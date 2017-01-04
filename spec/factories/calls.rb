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
#

FactoryGirl.define do
  factory :call do
    association :page, :with_call_tool
    member_phone_number { Faker::PhoneNumber.phone_number }
    target_index 0
  end
end

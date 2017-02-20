# frozen_string_literal: true
# == Schema Information
#
# Table name: plugins_call_tools
#
#  id         :integer          not null, primary key
#  page_id    :integer
#  active     :boolean
#  ref        :string
#  form_id    :integer
#  created_at :datetime
#  updated_at :datetime
#  title      :string
#  targets    :json             is an Array
#

FactoryGirl.define do
  factory :call_tool, class: 'Plugins::CallTool' do
    association :page
    targets { Array.new(3) { build(:call_tool_target, :with_country) } }
  end

  factory :call_tool_target, class: 'CallTool::Target' do
    skip_create
    name { Faker::Name.name }
    title { Faker::Name.title }
    phone_number { Faker::PhoneNumber.cell_phone }

    trait :with_country do
      country_name { 'United Kingdom' }
    end
  end
end

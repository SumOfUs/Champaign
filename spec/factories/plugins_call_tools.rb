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
    targets { 3.times.map { build(:call_tool_target) } }
  end

  factory :call_tool_target, class: 'CallTool::Target' do
    skip_create
    country_name {'United Kingdom'}
    name { Faker::Name.name }
    title { Faker::Name.title }
    phone_number { Faker::PhoneNumber.cell_phone }
  end
end

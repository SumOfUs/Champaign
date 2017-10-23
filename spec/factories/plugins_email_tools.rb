# frozen_string_literal: true

# == Schema Information
#
# Table name: plugins_email_tools
#
#  id                    :integer          not null, primary key
#  ref                   :string
#  page_id               :integer
#  active                :boolean          default("false")
#  email_subjects        :string           default("{}"), is an Array
#  email_body            :text
#  email_body_header     :text
#  email_body_footer     :text
#  test_email_address    :string
#  targets               :json             default("{}"), is an Array
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  use_member_email      :boolean          default("false")
#  from_email_address_id :integer
#  targeting_mode        :integer          default("0")
#  title                 :string           default("")
#

FactoryGirl.define do
  factory :email_tool, class: 'Plugins::EmailTool' do
    association :page
  end

  factory :email_tool_target, class: 'EmailTool::Target' do
    skip_create
    name { Faker::Name.name }
    email { Faker::Internet.email }
  end
end

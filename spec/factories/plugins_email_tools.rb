# frozen_string_literal: true

# == Schema Information
#
# Table name: plugins_email_tools
#
#  id                    :bigint(8)        not null, primary key
#  active                :boolean          default(FALSE)
#  email_body            :text
#  email_body_footer     :text
#  email_body_header     :text
#  email_subjects        :string           default([]), is an Array
#  ref                   :string
#  targeting_mode        :integer          default("member_selected_target")
#  targets               :json             is an Array
#  test_email_address    :string
#  title                 :string           default("")
#  use_member_email      :boolean          default(FALSE)
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  from_email_address_id :integer
#  page_id               :integer
#
# Indexes
#
#  index_plugins_email_tools_on_page_id  (page_id)
#

FactoryBot.define do
  factory :email_tool, class: 'Plugins::EmailTool' do
    association :page
  end

  factory :email_tool_target, class: 'EmailTool::Target' do
    skip_create
    name { Faker::Name.name }
    email { Faker::Internet.email }
  end
end

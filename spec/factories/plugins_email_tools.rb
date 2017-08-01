# frozen_string_literal: true

# == Schema Information
#
# Table name: plugins_email_tools
#
#  id                 :integer          not null, primary key
#  ref                :string
#  page_id            :integer
#  active             :boolean          default(FALSE)
#  email_from         :string
#  email_subject      :string
#  email_body_b       :text
#  created_at         :datetime
#  updated_at         :datetime
#  test_email_address :string
#  email_body_a       :text
#  email_body_c       :text
#

FactoryGirl.define do
  factory :email_tool, class: 'Plugins::EmailTool' do
    association :page
    email_from 'foo@example.com'
  end
end

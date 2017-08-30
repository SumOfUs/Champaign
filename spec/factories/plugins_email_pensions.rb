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
#

FactoryGirl.define do
  factory :email_pension, class: 'Plugins::EmailPension' do
    association :page
    email_from 'foo@example.com'
  end
end

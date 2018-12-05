# frozen_string_literal: true

# == Schema Information
#
# Table name: plugins_email_pensions
#
#  id                    :integer          not null, primary key
#  ref                   :string
#  page_id               :integer
#  active                :boolean          default("false")
#  email_subjects        :string           default("{}"), is an Array
#  email_body            :text
#  created_at            :datetime
#  updated_at            :datetime
#  test_email_address    :string
#  email_body_header     :text
#  email_body_footer     :text
#  use_member_email      :boolean          default("false")
#  from_email_address_id :integer
#

FactoryBot.define do
  factory :email_pension, class: 'Plugins::EmailPension' do
    association :page
  end
end

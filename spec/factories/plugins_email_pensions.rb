# frozen_string_literal: true

# == Schema Information
#
# Table name: plugins_email_pensions
#
#  id                            :integer          not null, primary key
#  active                        :boolean          default(FALSE)
#  email_body                    :text
#  email_body_footer             :text
#  email_body_header             :text
#  email_subjects                :string           default([]), is an Array
#  ref                           :string
#  test_email_address            :string
#  use_member_email              :boolean          default(FALSE)
#  created_at                    :datetime
#  updated_at                    :datetime
#  from_email_address_id         :integer
#  page_id                       :integer
#  registered_target_endpoint_id :integer
#
# Indexes
#
#  index_plugins_email_pensions_on_page_id  (page_id)
#

FactoryBot.define do
  factory :email_pension, class: 'Plugins::EmailPension' do
    association :page
  end
end

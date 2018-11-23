# frozen_string_literal: true

# == Schema Information
#
# Table name: actions
#
#  id                :integer          not null, primary key
#  page_id           :integer
#  member_id         :integer
#  link              :string
#  created_user      :boolean
#  subscribed_user   :boolean
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  form_data         :jsonb            default("{}")
#  subscribed_member :boolean          default("true")
#  donation          :boolean          default("false")
#  publish_status    :integer          default("0"), not null
#

FactoryBot.define do
  factory :action do
    page { nil }
    member { nil }
    link { 'MyString' }
    created_user { false }
    subscribed_user { false }

    trait :with_member_and_page do
      member
      page
    end
  end
end

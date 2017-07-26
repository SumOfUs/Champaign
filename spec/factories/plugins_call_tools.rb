# frozen_string_literal: true

# == Schema Information
#
# Table name: plugins_call_tools
#
#  id                            :integer          not null, primary key
#  page_id                       :integer
#  active                        :boolean
#  ref                           :string
#  created_at                    :datetime
#  updated_at                    :datetime
#  title                         :string
#  sound_clip_file_name          :string
#  sound_clip_content_type       :string
#  sound_clip_file_size          :integer
#  sound_clip_updated_at         :datetime
#  targets                       :json             default("{}"), is an Array
#  description                   :text
#  menu_sound_clip_file_name     :string
#  menu_sound_clip_content_type  :string
#  menu_sound_clip_file_size     :integer
#  menu_sound_clip_updated_at    :datetime
#  caller_phone_number_id        :integer
#  restricted_country_code       :string
#  target_by_attributes          :string           is an Array
#

FactoryGirl.define do
  factory :call_tool, class: 'Plugins::CallTool' do
    association :caller_phone_number, factory: :phone_number
    association :page
    targets { build_list(:call_tool_target, 3, :with_country) }
  end

  factory :call_tool_target, class: 'CallTool::Target' do
    skip_create
    name { Faker::Name.name }
    phone_number {
      ['+448008085429', '+448000119712', '+61261885481', '+13437003482'].sample
    }

    trait :with_country do
      country {
        ISO3166::Country.find_country_by_alpha2(Faker::Address.country_code).name
      }
    end

    trait :with_caller_id do
      fields {
        {
          caller_id: Faker::PhoneNumber.phone_number
        }
      }
    end
  end
end

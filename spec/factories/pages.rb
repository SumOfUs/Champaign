# frozen_string_literal: true

# == Schema Information
#
# Table name: pages
#
#  id                         :integer          not null, primary key
#  language_id                :integer
#  campaign_id                :integer
#  title                      :string           not null
#  slug                       :string           not null
#  created_at                 :datetime
#  updated_at                 :datetime
#  compiled_html              :text
#  status                     :string           default("pending")
#  messages                   :text
#  content                    :text             default("")
#  featured                   :boolean          default("false")
#  liquid_layout_id           :integer
#  follow_up_liquid_layout_id :integer
#  action_count               :integer          default("0")
#  primary_image_id           :integer
#  ak_petition_resource_uri   :string
#  ak_donation_resource_uri   :string
#  follow_up_plan             :integer          default("0"), not null
#  follow_up_page_id          :integer
#  javascript                 :text
#  publish_status             :integer          default("1"), not null
#  optimizely_status          :integer          default("0"), not null
#  canonical_url              :string
#  allow_duplicate_actions    :boolean          default("false")
#  enforce_styles             :boolean          default("false"), not null
#  notes                      :text
#  publish_actions            :integer          default("0"), not null
#  meta_tags                  :string
#  meta_description           :string
#

FactoryGirl.define do
  factory :page do
    sequence(:title) { |n| "#{Faker::Company.bs}#{n}" }
    slug nil # Used by friendly_id  http://norman.github.io/friendly_id/
    publish_status :published
    featured false
    liquid_layout
    language
    ak_petition_resource_uri 'http://example.com/petition'
    ak_donation_resource_uri 'http://example.com/donation'

    trait :featured do
      featured true
    end
    trait :published do
      publish_status :published
    end

    trait :unpublished do
      publish_status :unpublished
    end

    trait :with_petition do
      after(:create) do |page, _evaluator|
        create(:plugins_petition, page: page)
      end
    end

    trait :with_call_tool do
      after(:create) do |page, _evaluator|
        create(:call_tool, page: page)
      end
    end
  end
end

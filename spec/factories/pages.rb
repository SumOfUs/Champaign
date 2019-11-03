# frozen_string_literal: true

# == Schema Information
#
# Table name: pages
#
#  id                         :integer          not null, primary key
#  action_count               :integer          default(0)
#  ak_donation_resource_uri   :string
#  ak_petition_resource_uri   :string
#  allow_duplicate_actions    :boolean          default(FALSE)
#  canonical_url              :string
#  compiled_html              :text
#  content                    :text             default("")
#  enforce_styles             :boolean          default(TRUE), not null
#  featured                   :boolean          default(FALSE)
#  follow_up_plan             :integer          default("with_liquid"), not null
#  fundraising_goal           :decimal(10, 2)   default(0.0)
#  javascript                 :text
#  messages                   :text
#  meta_description           :string
#  meta_tags                  :string
#  notes                      :text
#  optimizely_status          :integer          default("optimizely_enabled"), not null
#  publish_actions            :integer          default("secure"), not null
#  publish_status             :integer          default("unpublished"), not null
#  slug                       :string           not null
#  status                     :string           default("pending")
#  title                      :string           not null
#  total_donations            :decimal(10, 2)   default(0.0)
#  created_at                 :datetime
#  updated_at                 :datetime
#  campaign_id                :integer
#  follow_up_liquid_layout_id :integer
#  follow_up_page_id          :integer
#  language_id                :integer
#  liquid_layout_id           :integer
#  primary_image_id           :integer
#
# Indexes
#
#  index_pages_on_campaign_id                 (campaign_id)
#  index_pages_on_follow_up_liquid_layout_id  (follow_up_liquid_layout_id)
#  index_pages_on_follow_up_page_id           (follow_up_page_id)
#  index_pages_on_liquid_layout_id            (liquid_layout_id)
#  index_pages_on_primary_image_id            (primary_image_id)
#  index_pages_on_publish_status              (publish_status)
#
# Foreign Keys
#
#  fk_rails_...  (campaign_id => campaigns.id)
#  fk_rails_...  (follow_up_liquid_layout_id => liquid_layouts.id)
#  fk_rails_...  (language_id => languages.id)
#  fk_rails_...  (liquid_layout_id => liquid_layouts.id)
#  fk_rails_...  (primary_image_id => images.id)
#

FactoryBot.define do
  factory :page do
    sequence(:title) { |n| "#{Faker::Company.bs}#{n}" }
    slug { nil } # Used by friendly_id  http://norman.github.io/friendly_id/
    publish_status { :published }
    featured { false }
    liquid_layout
    language
    ak_petition_resource_uri { 'http://example.com/petition' }
    ak_donation_resource_uri { 'http://example.com/donation' }
    total_donations { 0 }
    fundraising_goal { 0 }

    trait :featured do
      featured { true }
    end
    trait :published do
      publish_status { :published }
    end

    trait :unpublished do
      publish_status { :unpublished }
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

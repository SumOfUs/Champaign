FactoryGirl.define do
  factory :page do
    sequence(:title) {|n| "#{Faker::Company.bs}#{n}" }
    slug     nil # Used by friendly_id  http://norman.github.io/friendly_id/
    publish_status :published
    featured false
    liquid_layout
    language
    ak_petition_resource_uri "http://example.com/petition"
    ak_donation_resource_uri "http://example.com/donation"

    trait :published do
      publish_status :published
    end

    trait :unpublished do
      publish_status :unpublished
    end
  end
end


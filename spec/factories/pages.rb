FactoryGirl.define do
  factory :page do
    title    { Faker::Company.bs }
    slug     nil # Used by friendly_id  http://norman.github.io/friendly_id/
    active   true
    featured false
    liquid_layout
    language
    ak_petition_resource_uri "http://example.com/petition"
    ak_donation_resource_uri "http://example.com/donation"
  end
end


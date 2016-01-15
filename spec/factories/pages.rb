FactoryGirl.define do
  factory :page do
    title { Faker::Company.bs }
    slug { Faker::Internet.slug }
    active true
    featured false
    liquid_layout
    language
    ak_petition_resource_uri "http://example.com/petition"
    ak_donation_resource_uri "http://example.com/donation"
  end
end


FactoryGirl.define do
  factory :page do
    title { Faker::Company.bs }
    slug
    active true
    featured false
    liquid_layout
    language
  end
end


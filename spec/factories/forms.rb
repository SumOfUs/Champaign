FactoryGirl.define do
  factory :form do
    title { Faker::Name.name }
    description "A description"
  end
end

FactoryGirl.define do
  factory :liquid_partial do
    title { Faker::Company.bs }
    content "<div class='fun'>{{ title }}</div>"
  end
end

FactoryGirl.define do
  factory :campaign do
    sequence(:name) {|n| "#{Faker::Company.bs}#{n}" }
  end
end


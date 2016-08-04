FactoryGirl.define do
  factory :campaign do
    sequence(:name) {|n| "#{Faker::Company.bs}#{n.to_s}" }
  end
end


FactoryGirl.define do

  factory :liquid_layout do
    title { Faker::Company.bs }
    content "<div class='fun'>{ include 'thermometer' }</div>"
  end

end

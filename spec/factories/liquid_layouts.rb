FactoryGirl.define do

  factory :liquid_layout do
    title { Faker::Company.bs }
    content "<div class='fun'></div>"

    trait :master do
      title 'master'
      content %{ {% include 'action' %} {% include 'thermometer' %} }
    end

    trait :action do
      title 'action template'
      content %{ {% include 'action' %} }
    end

    trait :thermometer do
      title 'thermometer template'
      content %{ {% include 'thermometer' %} }
    end
  end

end

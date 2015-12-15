FactoryGirl.define do

  factory :liquid_layout do
    title { Faker::Company.bs }
    content "<div class='fun'></div>"

    trait :default do
      title 'default'
      content %{ {% include 'petition' %} {% include 'thermometer' %} }
    end

    trait :petition do
      title 'petition template'
      content %{ {% include 'petition' %} }
    end

    trait :thermometer do
      title 'thermometer template'
      content %{ {% include 'thermometer' %} }
    end

    trait :no_plugins do
      title 'layout with no plugins'
      content %{ whatever }
    end
  end

end

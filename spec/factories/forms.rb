FactoryGirl.define do
  factory :form do
    name { Faker::Name.name }
    description "A description"

    factory :form_with_fields do
      after(:create) do |form, evaluator|
        create_list(:form_element, 2, form: form)
      end
    end

  end
end

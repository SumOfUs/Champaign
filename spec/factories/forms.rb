FactoryGirl.define do
  factory :form do
    name { Faker::Name.name }
    description "A description"
    master false

    factory :form_with_email do
      after(:create) do |form, evaluator|
        create :form_element, form: form, name: 'email', label: 'Email'
      end
    end

    factory :form_with_fields do
      after(:create) do |form, evaluator|
        create_list(:form_element, 2, form: form)
      end
    end
  end
end

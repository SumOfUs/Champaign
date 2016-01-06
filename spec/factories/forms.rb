FactoryGirl.define do
  factory :form do
    name { Faker::Name.name }
    description "A description"
    master false

    factory :form_with_email do
      after(:create) do |form, evaluator|
        create :form_element, form: form, name: 'email', label: 'Email', data_type: 'email'
      end
    end

    factory :form_with_email_and_name do
      after(:create) do |form, evaluator|
        create :form_element, form: form, name: 'email', label: 'Email', data_type: 'email', required: true
        create :form_element, form: form, name: 'name', label: 'Full name', data_type: 'text', required: true
      end
    end

    factory :form_with_fields do
      after(:create) do |form, evaluator|
        create_list(:form_element, 2, form: form)
      end
    end
  end
end

# frozen_string_literal: true
FactoryGirl.define do
  factory :language do
    code 'en'
    name 'English'
    actionkit_uri '/rest/v1/language/102/'

    trait :english

    trait :french do
      code 'fr'
      name 'French'
    end

    trait :spanish do
      code 'es'
      name 'Spanish'
    end

    trait :german do
      code 'de'
      name 'German'
    end
  end
end

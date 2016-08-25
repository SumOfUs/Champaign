# frozen_string_literal: true
FactoryGirl.define do
  factory :form_element do
    form
    label     { Faker::Lorem.word }
    name      'address1'
    required  false
    data_type 'text'
    visible   true

    trait :email do
      label     'Email Address'
      name      'email'
      data_type 'email'
    end

    trait :phone do
      label     'Phone Number'
      name      'phone'
      data_type 'phone'
    end

    trait :country do
      label     'Country'
      name      'country'
      data_type 'country'
    end

    trait :postal do
      label     'Postal'
      name      'postal'
      data_type 'postal'
    end

    trait :paragraph do
      label     'Your thoughts'
      name      'comment'
      data_type 'paragraph'
    end
  end
end

# frozen_string_literal: true
FactoryGirl.define do
  factory :action do
    page nil
    member nil
    link 'MyString'
    created_user false
    subscribed_user false

    trait :with_member_and_page do
      member
      page
    end
  end
end

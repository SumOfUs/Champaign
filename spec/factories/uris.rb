# frozen_string_literal: true
FactoryGirl.define do
  factory :uri do
    domain "google.com"
    path "/"
    page_id nil
  end
end

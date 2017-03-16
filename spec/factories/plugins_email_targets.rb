# frozen_string_literal: true

FactoryGirl.define do
  factory :email_target, class: 'Plugins::EmailTarget' do
    association :page
    email_from 'foo@example.com'
  end
end


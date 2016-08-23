# frozen_string_literal: true
FactoryGirl.define do
  factory :share_twitter, :class => 'Share::Twitter' do
    sp_id 1
    page nil
    title "MyString"
    description "MyString {LINK}"
    button_id 1
  end
end

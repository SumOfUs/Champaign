# frozen_string_literal: true
FactoryGirl.define do
  factory :plugins_fundraiser, class: 'Plugins::Fundraiser' do
    title 'Donate now'
    ref nil
    active false
  end
end

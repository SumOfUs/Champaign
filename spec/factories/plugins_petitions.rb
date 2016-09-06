# frozen_string_literal: true
FactoryGirl.define do
  factory :plugins_petition, class: 'Plugins::Petition' do
    page nil
    active false
    form nil
    cta 'Sign the Petition'
    target 'The man'
    description 'Gotta save the world and stuff'
  end
end

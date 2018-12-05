# frozen_string_literal: true
# == Schema Information
#
# Table name: campaigns
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime
#  updated_at :datetime
#

FactoryBot.define do
  factory :campaign do
    sequence(:name) { |n| "#{Faker::Company.bs}#{n}" }
  end
end

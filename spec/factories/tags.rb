# frozen_string_literal: true

# == Schema Information
#
# Table name: tags
#
#  id            :integer          not null, primary key
#  name          :string
#  actionkit_uri :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

FactoryBot.define do
  factory :tag do
    sequence(:name) { |n| "#{['+', '@', '*'].sample}#{Faker::Commerce.color}#{n}" }
    actionkit_uri
  end
end

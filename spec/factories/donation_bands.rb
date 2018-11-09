# frozen_string_literal: true

# == Schema Information
#
# Table name: donation_bands
#
#  id         :integer          not null, primary key
#  name       :string
#  amounts    :integer          default("{}"), is an Array
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryBot.define do
  factory :donation_band do
    name { Faker::Internet.slug }
    amounts { [rand(20), rand(300), rand(300), rand(300), rand(300)].map { |fl| fl.to_i * 100 }.sort }
  end
end

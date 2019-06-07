# == Schema Information
#
# Table name: pension_funds
#
#  id           :bigint(8)        not null, primary key
#  active       :boolean          default(TRUE), not null
#  country_code :string           not null
#  email        :string
#  fund         :string           not null
#  name         :string           not null
#  uuid         :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_pension_funds_on_country_code  (country_code)
#  index_pension_funds_on_uuid          (uuid) UNIQUE
#

FactoryBot.define do
  factory :pension_fund do
    fund { Faker::Company.name }
    name { Faker::Name.name }
    sequence(:email) { |n| "person#{n}@example.com" }
    country_code { %w[AU IS DK].sample }
  end
end

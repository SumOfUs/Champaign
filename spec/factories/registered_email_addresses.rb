# == Schema Information
#
# Table name: registered_email_addresses
#
#  id    :bigint(8)        not null, primary key
#  email :string
#  name  :string
#

FactoryBot.define do
  factory :registered_email_address do
    email { Faker::Internet.email }
    name { Faker::Name.name }
  end
end

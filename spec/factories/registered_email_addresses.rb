# == Schema Information
#
# Table name: registered_email_addresses
#
#  id    :integer          not null, primary key
#  email :string
#  name  :string
#

FactoryGirl.define do
  factory :registered_email_address do
    email { Faker::Internet.email }
    name { Faker::Name.name }
  end
end

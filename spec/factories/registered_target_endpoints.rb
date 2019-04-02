# == Schema Information
#
# Table name: registered_target_endpoints
#
#  id          :bigint(8)        not null, primary key
#  description :text
#  name        :string
#  url         :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

FactoryBot.define do
  factory :registered_target_endpoint do
    url { 'MyString' }
    name { 'MyString' }
    description { 'MyText' }
  end
end

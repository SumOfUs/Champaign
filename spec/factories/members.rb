# frozen_string_literal: true
# == Schema Information
#
# Table name: members
#
#  id                :integer          not null, primary key
#  email             :string
#  country           :string
#  first_name        :string
#  last_name         :string
#  city              :string
#  postal            :string
#  title             :string
#  address1          :string
#  address2          :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  actionkit_user_id :string
#  donor_status      :integer          default(0), not null
#  more              :jsonb
#

FactoryGirl.define do
  factory :member do
    email { Faker::Internet.email }
    actionkit_user_id { Faker::Number.number(10) }
  end
end
